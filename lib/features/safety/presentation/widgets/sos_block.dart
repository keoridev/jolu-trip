import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/models/models.dart';

class SosBlock extends StatelessWidget {
  final GpsCoordinates? coordinates;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onSos;

  const SosBlock({
    super.key,
    required this.coordinates,
    required this.isLoading,
    required this.onRefresh,
    required this.onSos,
  });

  Future<void> _copyCoordinates(BuildContext context) async {
    if (coordinates == null) return;
    final text = '${coordinates!.decimal}\n${coordinates!.dms}';
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Координаты скопированы'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.2),
            AppColors.error.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.spaceM),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GPS Координаты',
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onRefresh,
                        child: Icon(
                          Icons.refresh,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.spaceM),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coordinates?.decimal ?? '--.------, --.------',
                        style: AppTextStyles.body.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coordinates?.dms ?? '--° --\' --" N --° --\' --" E',
                        style: AppTextStyles.subtext.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spaceS),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: coordinates != null
                        ? () => _copyCoordinates(context)
                        : null,
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    label: Text('Скопировать', style: AppTextStyles.subtext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppDimens.spaceM),
            child: ElevatedButton.icon(
              onPressed: onSos,
              icon: const Icon(Icons.emergency, color: Colors.white),
              label: Text(
                'Вызвать МЧС 112',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
