import 'package:flutter/material.dart';
import 'custom_button.dart';
import '../constants.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    this.message = 'Terjadi kesalahan',
    this.buttonLabel = 'Coba Lagi',
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                label: buttonLabel ?? 'Coba Lagi',
                onPressed: onRetry,
                isOutlined: true,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InternetErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const InternetErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: 'Tidak ada koneksi internet. Periksa koneksi Anda.',
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: 'Server sedang sibuk. Silakan coba lagi.',
      icon: Icons.cloud_off_outlined,
      onRetry: onRetry,
    );
  }
}

class GpsErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const GpsErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: 'GPS tidak aktif. Aktifkan GPS untuk melanjutkan.',
      icon: Icons.gps_off_outlined,
      onRetry: onRetry,
    );
  }
}
