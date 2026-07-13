import 'package:flutter/material.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';

class LocationSearchSheet extends StatefulWidget {
  final void Function(String id, String name) onSelect;

  const LocationSearchSheet({super.key, required this.onSelect});

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _locations = [
    {'id': '1', 'name': 'Озеро Сон-Куль'},
    {'id': '2', 'name': 'Ала-Арча'},
    {'id': '3', 'name': 'Бурана'},
    {'id': '4', 'name': 'Джети-Огуз'},
    {'id': '5', 'name': 'Сказка каньон'},
    {'id': '6', 'name': 'Иссык-Куль'},
    {'id': '7', 'name': 'Кол-Тор'},
    {'id': '8', 'name': 'Конорчек'},
  ];

  List<Map<String, String>> get _filtered {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _locations;
    return _locations
        .where((l) => l['name']!.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimens.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          const SizedBox(height: AppDimens.space20),
          _SearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppDimens.space16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final loc = _filtered[index];
                return _LocationItem(
                  name: loc['name']!,
                  onTap: () => widget.onSelect(loc['id']!, loc['name']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Поиск локации...',
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _LocationItem({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.location_on, color: AppColors.primary),
      title: Text(
        name,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
