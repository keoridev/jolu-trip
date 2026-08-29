import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/entities/health_card_entity.dart';
import 'package:jolutrip_app/features/tourist_health_card/domain/repositories/health_card_repository.dart';

class HealthCardStatusBlock extends StatefulWidget {
  const HealthCardStatusBlock({super.key});

  @override
  State<HealthCardStatusBlock> createState() => _HealthCardStatusBlockState();
}

class _HealthCardStatusBlockState extends State<HealthCardStatusBlock> {
  HealthCardEntity? _card;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    try {
      final result = await sl<HealthCardRepository>().getHealthCard();
      if (!mounted) return;

      result.fold(
        (failure) => setState(() {
          _error = failure.message;
          _isLoading = false;
        }),
        (card) => setState(() {
          _card = card;
          _isLoading = false;
        }),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _goToHealthCard() {
    context.push('/tourist/health-card/view'); // ← было '/tourist/health-card'
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();

    if (_error != null && _card == null) return _buildErrorBanner();

    if (_card == null || _card!.isEmpty) return _buildEmptyBanner();

    return _buildFilledBanner(_card!);
  }

  Widget _buildSkeleton() {
    return Container(
      width: double.infinity,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.borderDark),
      ),
    );
  }

  // ─── Ошибка с retry ─────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return _BaseBanner(
      accentColor: AppColors.textTertiary,
      icon: Icons.sync_problem_rounded,
      title: 'Не удалось загрузить карточку',
      subtitle: 'Проверьте соединение и попробуйте снова',
      actionLabel: 'Обновить',
      onTap: () {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        _loadCard();
      },
    );
  }

  Widget _buildEmptyBanner() {
    return _BaseBanner(
      accentColor: AppColors.warning,
      icon: Icons.shield_outlined,
      title: 'Заполните карточку здоровья',
      subtitle:
          'Группа крови, аллергии и экстренный контакт — для вашей безопасности в поездках',
      actionLabel: 'Заполнить',
      onTap: () async {
        await context.push('/tourist/health-card');
        if (mounted) _loadCard(); // перезагружаем после редактирования
      },
    );
  }

  Widget _buildFilledBanner(HealthCardEntity card) {
    return _BaseBanner(
      accentColor: AppColors.success,
      icon: Icons.verified_user_rounded,
      title: 'Карточка здоровья заполнена',
      subtitle: _buildSummary(card),
      actionLabel: 'Посмотреть',
      onTap: () async {
        await context.push('/tourist/health-card/view');
        if (mounted) _loadCard();
      },
      trailing: card.bloodType.isNotEmpty ? _BloodBadge(card.bloodType) : null,
    );
  }

  String _buildSummary(HealthCardEntity card) {
    final parts = <String>[];
    if (card.allergies.isNotEmpty) parts.add('Аллергии');
    if (card.chronicDiseases.isNotEmpty) parts.add('Хронические');
    if (card.emergencyContact.isNotEmpty) {
      parts.add('Экстр. контакт: ${card.emergencyContact.name}');
    }
    if (parts.isEmpty) return 'Базовая информация внесена';
    return parts.join(' • ');
  }
}

// ═══════════════════════════════════════════════════════════════
// Базовый баннер
// ═══════════════════════════════════════════════════════════════
class _BaseBanner extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final Widget? trailing;

  const _BaseBanner({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.14),
                accentColor.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimens.radius16),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: AppDimens.space8),
                          trailing!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.space8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentColor.withValues(alpha: 0.7),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Бейдж группы крови
// ═══════════════════════════════════════════════════════════════
class _BloodBadge extends StatelessWidget {
  final String bloodType;
  const _BloodBadge(this.bloodType);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space10,
        vertical: AppDimens.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Text(
        bloodType,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
