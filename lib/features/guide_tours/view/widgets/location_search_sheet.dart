import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jolutrip_app/core/di/service_locator.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/features/locations/domain/entities/location_entity.dart';
import 'package:jolutrip_app/features/locations/view/bloc/locations_cubit.dart';

class LocationSearchSheet extends StatefulWidget {
  final void Function(String id, String name) onSelect;

  const LocationSearchSheet({super.key, required this.onSelect});

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final _searchController = TextEditingController();
  late final LocationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<LocationsCubit>();
    _cubit.loadLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<LocationsCubit, LocationsState>(
        builder: (context, state) {
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
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (state.error != null)
                  _ErrorState(message: state.error!)
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filtered(state.locations).length,
                      itemBuilder: (context, index) {
                        final loc = _filtered(state.locations)[index];
                        return _LocationItem(
                          name: loc.name,
                          onTap: () => widget.onSelect(loc.id, loc.name),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<LocationEntity> _filtered(List<LocationEntity> locations) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return locations;
    return locations
        .where((l) => l.name.toLowerCase().contains(query))
        .toList();
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

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
