import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/data/datasources/safety_local_datasource.dart';
import 'package:jolutrip_app/features/safety/data/models/safety_models.dart';
import 'package:jolutrip_app/features/safety/view/widgets/shared/block_title.dart';
import 'package:url_launcher/url_launcher.dart';

class DigitalToolboxBlock extends StatelessWidget {
  const DigitalToolboxBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <String, List<AppInfo>>{};
    for (final app in SafetyLocalDataSource.essentialApps) {
      categories.putIfAbsent(app.category, () => []).add(app);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BlockTitle(
          icon: Icons.backpack_outlined,
          title: 'Туристический набор',
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimens.space24),
        ...categories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: AppDimens.space12, bottom: AppDimens.space16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: entry.value.first.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppDimens.space12),
                    Text(
                      entry.key,
                      style: AppTextStyles.subtext.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((app) => _AppCard(app: app)),
              const SizedBox(height: AppDimens.space24),
            ],
          );
        }),
        const SizedBox(height: AppDimens.space32),
        const BlockTitle(
          icon: Icons.signal_cellular_alt_rounded,
          title: 'Связь в горах',
          color: AppColors.accent,
        ),
        const SizedBox(height: AppDimens.space16),
        Row(
          children: SafetyLocalDataSource.operators
              .map(
                (op) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _OperatorCard(operator: op),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AppCard extends StatelessWidget {
  final AppInfo app;
  const _AppCard({required this.app});

  Future<void> _launchApp() async {
    final uri = Uri.parse(app.fallbackUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Material(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: InkWell(
          onTap: _launchApp,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        app.color.withValues(alpha: 0.3),
                        app.color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Center(
                    child: app.assetPath != null
                        ? Image.asset(
                            app.assetPath!,
                            width: 28,
                            height: 28,
                            errorBuilder: (_, __, ___) => _FallbackIcon(app: app),
                          )
                        : _FallbackIcon(app: app),
                  ),
                ),
                const SizedBox(width: AppDimens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            app.name,
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: app.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              app.category,
                              style: TextStyle(color: app.color, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.description,
                        style: AppTextStyles.subtext.copyWith(fontSize: 12, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.north_east, color: AppColors.primary, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final AppInfo app;
  const _FallbackIcon({required this.app});

  @override
  Widget build(BuildContext context) {
    return Text(
      app.name[0],
      style: TextStyle(color: app.color, fontSize: 22, fontWeight: FontWeight.w800),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final OperatorInfo operator;
  const _OperatorCard({required this.operator});

  Future<void> _openUrl() async {
    final uri = Uri.parse(operator.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      child: InkWell(
        onTap: _openUrl,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.space24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      operator.color.withValues(alpha: 0.3),
                      operator.color.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: operator.assetPath != null
                      ? Image.asset(
                          operator.assetPath!,
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => _OperatorFallback(operator: operator),
                        )
                      : _OperatorFallback(operator: operator),
                ),
              ),
              const SizedBox(height: AppDimens.space12),
              Text(
                operator.name,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  operator.coverage,
                  style: AppTextStyles.subtext.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperatorFallback extends StatelessWidget {
  final OperatorInfo operator;
  const _OperatorFallback({required this.operator});

  @override
  Widget build(BuildContext context) {
    return Text(
      operator.name[0],
      style: TextStyle(color: operator.color, fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}