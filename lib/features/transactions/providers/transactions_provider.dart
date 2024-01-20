import 'package:aqua/config/config.dart';
import 'package:aqua/data/models/gdk_models.dart';
import 'package:aqua/data/provider/aqua_provider.dart';
import 'package:aqua/data/provider/bitcoin_provider.dart';
import 'package:aqua/data/provider/fiat_provider.dart';
import 'package:aqua/data/provider/formatter_provider.dart';
import 'package:aqua/data/provider/liquid_provider.dart';
import 'package:aqua/features/settings/settings.dart';
import 'package:aqua/features/shared/shared.dart';
import 'package:aqua/features/transactions/transactions.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'package:aqua/constants.dart';

final rawTransactionsProvider =
    StreamProvider.family<List<GdkTransaction>, Asset>((ref, asset) async* {
  yield* asset.isBTC
      ? ref
          .read(bitcoinProvider)
          .transactionEventSubject
          .startWith(null)
          .asyncMap((_) =>
              ref.read(bitcoinProvider).getTransactions(requiresRefresh: true))
          .map((transactions) => transactions ?? [])
      : ref
          .read(liquidProvider)
          .transactionEventSubject
          .startWith(null)
          .asyncMap((_) =>
              ref.read(liquidProvider).getTransactions(requiresRefresh: true))
          .map((transactions) => transactions ?? [])
          .map((transactions) => transactions
              .where((transaction) => transaction.satoshi?[asset.id] != null)
              .toList());
});

final _rateStreamProvider = StreamProvider.autoDispose((ref) async* {
  yield* ref.read(fiatProvider).rateStream.distinctUnique();
});

final _transactionOtherAssetProvider = FutureProvider.autoDispose
    .family<Asset?, (Asset, GdkTransaction)>((ref, tuple) async {
  final asset = tuple.$1;
  final transaction = tuple.$2;

  if (transaction.type == GdkTransactionTypeEnum.swap) {
    final assets = ref.read(assetsProvider).asData?.value ?? [];

    if (asset.id == transaction.swapOutgoingAssetId) {
      final rawAsset = await ref
          .read(aquaProvider)
          .gdkRawAssetForAssetId(transaction.swapIncomingAssetId!);
      return assets.firstWhereOrNull((asset) => asset.id == rawAsset?.assetId);
    }

    final rawAsset = await ref
        .read(aquaProvider)
        .gdkRawAssetForAssetId(transaction.swapOutgoingAssetId!);
    return assets.firstWhereOrNull((asset) => asset.id == rawAsset?.assetId);
  }

  return null;
});

final _currentBlockHeightProvider =
    StreamProvider.autoDispose.family<int, Asset>((ref, asset) {
  return asset.isBTC
      ? ref.read(bitcoinProvider).blockHeightEventSubject
      : ref.read(liquidProvider).blockHeightEventSubject;
});

final fiatAmountProvider = FutureProvider.autoDispose
    .family<String, TransactionUiModel>((ref, model) async {
  final rate = ref.watch(_rateStreamProvider).asData?.value;

  final fiats = ref.read(fiatProvider);
  if (rate != null) {
    final amount = model.transaction.satoshi?[model.asset.id] as int;
    final fiat = fiats.satoshiToFiat(model.asset, amount, rate);
    final formattedFiat = fiats.formattedFiat(fiat);
    final currency = await fiats.currencyStream.first;
    return '$currency $formattedFiat';
  } else {
    return '';
  }
});

final transactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionUiModel>, Asset>((ref, asset) async {
  final rawTransactions =
      ref.watch(rawTransactionsProvider(asset)).asData?.value ?? [];

  return Future.wait(rawTransactions.mapIndexed((index, transaction) async {
    final currentBlockHeight =
        ref.watch(_currentBlockHeightProvider(asset)).asData?.value ?? 0;
    final transactionBlockHeight = transaction.blockHeight ?? 0;
    final confirmationCount = transactionBlockHeight == 0
        ? 0
        : currentBlockHeight - transactionBlockHeight + 1;
    final pending = asset.isBTC
        ? confirmationCount < onchainConfirmationBlockCount
        : confirmationCount < liquidConfirmationBlockCount;
    final String assetIcon = pending
        ? Svgs.pending
        : switch (transaction.type) {
            GdkTransactionTypeEnum.incoming => Svgs.incoming,
            GdkTransactionTypeEnum.outgoing => Svgs.outgoing,
            GdkTransactionTypeEnum.redeposit ||
            GdkTransactionTypeEnum.swap =>
              Svgs.exchange,
            _ => throw AssetTransactionsInvalidTypeException(),
          };
    final createdAt = transaction.createdAtTs != null
        ? DateFormat.yMMMd().format(
            DateTime.fromMicrosecondsSinceEpoch(transaction.createdAtTs!))
        : '';
    final formatter = ref.read(formatterProvider);
    final amount = transaction.satoshi?[asset.id] as int;
    final formattedAmount = switch (transaction.type) {
      GdkTransactionTypeEnum.swap ||
      GdkTransactionTypeEnum.incoming ||
      GdkTransactionTypeEnum.outgoing ||
      GdkTransactionTypeEnum.redeposit =>
        formatter.signedFormatAssetAmount(
          amount: amount,
          precision: asset.precision,
        ),
      _ => throw AssetTransactionsInvalidTypeException(),
    };
    final cryptoAmount = formattedAmount;

    final otherAsset = ref
        .watch(_transactionOtherAssetProvider((asset, transaction)))
        .asData
        ?.value;

    return TransactionUiModel(
      createdAt: createdAt,
      cryptoAmount: cryptoAmount,
      icon: assetIcon,
      asset: asset,
      otherAsset: otherAsset,
      transaction: transaction,
    );
  }).toList());
});

class AssetTransactionsInvalidTypeException implements Exception {}
