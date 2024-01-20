import 'package:aqua/config/constants/animations.dart' as animation;
import 'package:aqua/features/shared/shared.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';

enum WalletProcessType {
  create,
  restore,
}

class WalletProcessingAnimation extends HookConsumerWidget {
  const WalletProcessingAnimation({super.key, required this.type});

  final WalletProcessType type;

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      Future.microtask(() {
        ref.read(systemOverlayColorProvider(context)).forceLight();
      });
      return null;
    }, []);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                animation.walletProcessing,
                repeat: true,
                width: 132.r,
                height: 132.r,
                frameRate: FrameRate(120),
                fit: BoxFit.contain,
              ),
              SizedBox(height: 26.h),
              Text(
                type == WalletProcessType.create
                    ? AppLocalizations.of(context)!.walletCreateAnimationTitle
                    : AppLocalizations.of(context)!.walletRestoreAnimationTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 20.sp,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
