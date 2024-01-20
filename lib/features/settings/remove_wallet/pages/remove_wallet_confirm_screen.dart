import 'package:aqua/common/widgets/aqua_elevated_button.dart';
import 'package:aqua/config/config.dart';
import 'package:aqua/features/backup/providers/backup_reminder_provider.dart';
import 'package:aqua/features/settings/settings.dart';
import 'package:aqua/features/shared/shared.dart';
import 'package:aqua/utils/extensions/context_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restart_app/restart_app.dart';

class RemoveWalletConfirmScreen extends HookConsumerWidget {
  static const routeName = '/removeWalletConfirmScreen';

  const RemoveWalletConfirmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removeWalletState = ref.watch(walletRemoveRequestProvider);

    ref.listen(
      walletRemoveRequestProvider,
      (_, state) => state.maybeWhen(
        success: () async {
          await ref.read(backupReminderProvider).clear();
          Restart.restartApp();
          return null;
        },
        failure: () => context.showErrorSnackbar(
          AppLocalizations.of(context)!.removeWalletScreenRemoveFailed,
        ),
        verificationFailed: () => context.showErrorSnackbar(
          AppLocalizations.of(context)!.removeWalletScreenVerificationFailed,
        ),
        orElse: () => null,
      ),
    );

    return Scaffold(
      appBar: AquaAppBar(
        showActionButton: false,
        iconBackgroundColor: Theme.of(context).colorScheme.background,
        iconForegroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SafeArea(
        child: removeWalletState.maybeWhen(
          removing: () => const Center(child: CircularProgressIndicator()),
          orElse: () => const _ConfirmationView(),
        ),
      ),
    );
  }
}

class _ConfirmationView extends ConsumerWidget {
  const _ConfirmationView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          SizedBox(height: 60.h),
          const Spacer(),
          //ANCHOR - Icon
          SvgPicture.asset(
            Svgs.failure,
            width: 60.r,
            height: 60.r,
          ),
          SizedBox(height: 20.h),
          //ANCHOR - Title
          Text(
            AppLocalizations.of(context)!.removeWalletScreenTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                ),
          ),
          SizedBox(height: 8.h),
          //ANCHOR - Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              AppLocalizations.of(context)!.removeWalletScreenDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
          const Spacer(),
          //ANCHOR - Cancel button
          AquaElevatedButton(
            child: Text(
              AppLocalizations.of(context)!.removeWalletScreenCancelButton,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: 27.h),
          //ANCHOR - Confirm button
          AquaElevatedButton(
            onPressed: () => ref
                .read(walletRemoveRequestProvider.notifier)
                .requestWalletRemove(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              AppLocalizations.of(context)!.removeWalletScreenConfirmButton,
            ),
          ),
          SizedBox(height: 64.h),
        ],
      ),
    );
  }
}
