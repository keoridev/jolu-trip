import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/safety/bloc/safety_cubit.dart';
import 'package:jolutrip_app/features/safety/bloc/safety_state.dart';
import 'package:jolutrip_app/features/safety/data/datasources/safety_local_datasource.dart';
import 'package:jolutrip_app/features/safety/presentation/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SafetyCubit>()..loadLocation(),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppDimens.screenPadding,
                  child: BlocBuilder<SafetyCubit, SafetyState>(
                    builder: (context, state) {
                      final coordinates = state is SafetyLocationLoaded
                          ? state.coordinates
                          : null;
                      final isLoading =
                          state is SafetyLocationLoaded && state.isLoading;

                      return SosBlock(
                        coordinates: coordinates,
                        isLoading: isLoading,
                        onRefresh: () =>
                            context.read<SafetyCubit>().refreshLocation(),
                        onSos: _callEmergency,
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.spaceXL),
              ),
              _buildContentSections(),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Безопасность\nи помощь',
              style: AppTextStyles.headline.copyWith(fontSize: 32, height: 1.1),
            ),
            const SizedBox(height: AppDimens.spaceS),
            Text('Всё, что спасёт жизнь в горах', style: AppTextStyles.subtext),
            const SizedBox(height: AppDimens.spaceXL),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildContentSections() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppDimens.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableSection(
              icon: Icons.shield_outlined,
              title: 'Подготовка к выезду',
              subtitle: 'Приложения, связь, покрытие',
              items: [
                ExpandableItem(
                  icon: Icons.apps_outlined,
                  title: 'Обязательные приложения',
                  content: Column(
                    children: [
                      ...SafetyLocalDataSource.safetyContent['apps']!
                          .map<Widget>(
                            (app) => AppCard(
                              name: app['name'] as String,
                              description: app['description'] as String,
                              icon: app['icon'] as IconData,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
                ExpandableItem(
                  icon: Icons.signal_cellular_alt,
                  title: 'Связь и операторы',
                  content: _buildOperatorsContent(),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceL),
            ExpandableSection(
              icon: Icons.mosque_outlined,
              title: 'Культурный этикет',
              subtitle: "Do's and Don'ts в Кыргызстане",
              items: [
                ExpandableItem(
                  icon: Icons.checkroom_outlined,
                  title: 'Дресс-код',
                  content: InfoCard(
                    icon: Icons.info_outline,
                    color: AppColors.warning,
                    text:
                        SafetyLocalDataSource.safetyContent['dressCode']
                            as String,
                  ),
                ),
                ExpandableItem(
                  icon: Icons.home_outlined,
                  title: 'Правила в юртах',
                  content: Column(
                    children: [
                      ...(SafetyLocalDataSource.safetyContent['yurtRules']
                              as List<String>)
                          .map<Widget>(
                            (rule) => RuleCard(
                              icon: Icons.block,
                              text: rule,
                              isWarning: true,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
                ExpandableItem(
                  icon: Icons.eco_outlined,
                  title: 'Эко-манифест',
                  content: Column(
                    children: [
                      ...(SafetyLocalDataSource.safetyContent['ecoManifest']
                              as List<String>)
                          .map<Widget>(
                            (rule) => RuleCard(
                              icon: Icons.delete_outline,
                              text: rule,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.spaceL),
            ExpandableSection(
              icon: Icons.translate,
              title: 'Разговорник',
              subtitle: 'Базовый кыргызский',
              items: [
                ExpandableItem(
                  icon: Icons.record_voice_over_outlined,
                  title: 'Основные фразы',
                  content: Column(
                    children: [
                      ...(SafetyLocalDataSource.safetyContent['phrases']
                              as List<Map<String, dynamic>>)
                          .asMap()
                          .entries
                          .map<Widget>(
                            (entry) => PhraseCard(
                              number: entry.key + 1,
                              kyrgyz: entry.value['kyrgyz'] as String,
                              russian: entry.value['russian'] as String,
                              transcription:
                                  entry.value['transcription'] as String,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorsContent() {
    final operators =
        SafetyLocalDataSource.safetyContent['operators']
            as List<Map<String, dynamic>>;

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Column(
        children: [
          for (int i = 0; i < operators.length; i++) ...[
            OperatorRow(
              name: operators[i]['name'] as String,
              coverage: operators[i]['coverage'] as String,
              color: operators[i]['color'] as Color,
            ),
            if (i < operators.length - 1)
              const Divider(color: AppColors.borderDark, height: 16),
          ],
          const SizedBox(height: AppDimens.spaceM),
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Купите SIM в аэропорту Манас сразу по прилёте',
                    style: AppTextStyles.subtext.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
