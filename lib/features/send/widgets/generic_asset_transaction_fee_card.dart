import 'package:aqua/config/config.dart';
import 'package:aqua/features/send/providers/send_asset_fee_provider.dart';
import 'package:aqua/features/send/send.dart';
import 'package:aqua/features/settings/manage_assets/models/assets.dart';
import 'package:aqua/features/shared/shared.dart';

class GenericAssetTransactionFeeCard extends HookConsumerWidget {
  const GenericAssetTransactionFeeCard({
    super.key,
    required this.arguments,
  });

  final SendAssetArguments arguments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeToDisplay = ref.watch(feeToDisplayProvider(arguments.asset));
    final amountToDisplay = ref.watch(amountMinusFeesToDisplayProvider);
    final totalToDisplay =
        ref.watch(amountWithFeesToDisplayProvider(arguments.asset));

    return BoxShadowCard(
        color: Theme.of(context).colors.altScreenSurface,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //ANCHOR - "Send To" plus address
              if (arguments.asset.isLightning) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        AppLocalizations.of(context)!
                            .sendAssetReviewScreenSendTo),
                    Text(AppLocalizations.of(context)!.lightningInvoice)
                  ],
                ),
              ],

              // ANCHOR - Fee breakdown
              SizedBox(
                // width: 150.w,
                child: Column(
                  children: [
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            AppLocalizations.of(context)!
                                .sendAssetReviewScreenAmount),
                        Text(amountToDisplay != null
                            ? amountToDisplay.toString()
                            : '')
                      ],
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            AppLocalizations.of(context)!
                                .sendAssetReviewScreenFee),
                        Text(feeToDisplay ?? '')
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    const Divider(color: Colors.black12),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            AppLocalizations.of(context)!
                                .sendAssetReviewScreenTotal),
                        Text(
                          totalToDisplay ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
