import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/core/theme/app_dimens.dart';
import 'package:jolutrip_app/core/theme/app_text_styles.dart';
import 'package:jolutrip_app/core/ui/jolu_ui.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/create_tour_entity.dart';
import 'package:jolutrip_app/features/guide_tours/domain/entities/itinerary_day_entity.dart';
import 'package:jolutrip_app/features/guide_tours/view/bloc/guide_tours_cubit.dart';

class CreateTourScreen extends StatefulWidget {
  const CreateTourScreen({super.key});

  @override
  State<CreateTourScreen> createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends State<CreateTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationIdController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  final _minSeatsController = TextEditingController(text: '1');

  DateTime? _departureDate;
  int _durationDays = 1;
  final List<ItineraryDayEntity> _itinerary = [];
  final List<String> _includedServices = [];
  final List<String> _gearRequirements = [];

  final _serviceController = TextEditingController();
  final _gearController = TextEditingController();
  final _itineraryDayController = TextEditingController();
  final _itineraryDescController = TextEditingController();

  XFile? _selectedVideo;

  @override
  void dispose() {
    _titleController.dispose();
    _locationIdController.dispose();
    _priceController.dispose();
    _totalSeatsController.dispose();
    _minSeatsController.dispose();
    _serviceController.dispose();
    _gearController.dispose();
    _itineraryDayController.dispose();
    _itineraryDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Text('Создать тур', style: AppTextStyles.headline),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<GuideToursCubit, GuideToursState>(
        listener: (context, state) {
          if (state is GuideToursCreated) {
            JoluSnackbar.show(
              context: context,
              message: 'Тур успешно создан!',
              type: JoluSnackbarType.success,
            );
            context.pop();
          } else if (state is GuideToursError) {
            JoluSnackbar.show(
              context: context,
              message: state.message,
              type: JoluSnackbarType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GuideToursVideoUploading || state is GuideToursCreating;

          return Form(
            key: _formKey,
            child: ListView(
              padding: AppDimens.screenPadding,
              children: [
                _buildVideoSection(state),
                const SizedBox(height: AppDimens.space24),

                _buildTextField(
                  controller: _titleController,
                  label: 'Название тура',
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательно' : null,
                ),
                const SizedBox(height: AppDimens.space16),

                _buildTextField(
                  controller: _locationIdController,
                  label: 'ID локации',
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательно' : null,
                ),
                const SizedBox(height: AppDimens.space16),

                _buildDatePicker(),
                const SizedBox(height: AppDimens.space16),

                _buildDurationSelector(),
                const SizedBox(height: AppDimens.space16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _totalSeatsController,
                        label: 'Всего мест',
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Обязательно' : null,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space16),
                    Expanded(
                      child: _buildTextField(
                        controller: _minSeatsController,
                        label: 'Мин. мест',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space16),

                _buildTextField(
                  controller: _priceController,
                  label: 'Цена за место (сом)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? 'Обязательно' : null,
                ),
                const SizedBox(height: AppDimens.space24),

                _buildSectionTitle('Включённые услуги'),
                _buildChipsList(
                  items: _includedServices,
                  controller: _serviceController,
                  hint: 'Добавить услугу',
                  onAdd: (v) => setState(() => _includedServices.add(v)),
                  onRemove: (i) => setState(() => _includedServices.removeAt(i)),
                ),
                const SizedBox(height: AppDimens.space24),

                _buildSectionTitle('Необходимое снаряжение'),
                _buildChipsList(
                  items: _gearRequirements,
                  controller: _gearController,
                  hint: 'Добавить снаряжение',
                  onAdd: (v) => setState(() => _gearRequirements.add(v)),
                  onRemove: (i) => setState(() => _gearRequirements.removeAt(i)),
                ),
                const SizedBox(height: AppDimens.space24),

                _buildSectionTitle('Маршрут по дням'),
                ..._itinerary.asMap().entries.map((entry) {
                  return ListTile(
                    title: Text('День ${entry.value.day}', style: AppTextStyles.subtitle),
                    subtitle: Text(entry.value.description, style: AppTextStyles.body),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => setState(() => _itinerary.removeAt(entry.key)),
                    ),
                  );
                }),
                _buildAddItineraryDay(),
                const SizedBox(height: AppDimens.space32),

                JoluButton(
                  text: 'Создать тур',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _onSubmit,
                ),
                const SizedBox(height: AppDimens.space32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoSection(GuideToursState state) {
    final hasVideo = _selectedVideo != null;
    final isUploading = state is GuideToursVideoUploading;

    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(
            color: hasVideo ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUploading)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                Icon(
                  hasVideo ? Icons.videocam : Icons.add_circle_outline,
                  size: 48,
                  color: hasVideo ? AppColors.primary : AppColors.textSecondary,
                ),
              const SizedBox(height: 8),
              Text(
                hasVideo
                    ? 'Видео выбрано (${_selectedVideo!.name})'
                    : isUploading
                        ? 'Загрузка видео...'
                        : 'Добавить промо-видео',
                style: AppTextStyles.body.copyWith(
                  color: hasVideo ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final formatted = _departureDate != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(_departureDate!)
        : 'Выберите дату отправления';

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (date == null) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (time == null) return;

        setState(() {
          _departureDate = DateTime(
            date.year, date.month, date.day, time.hour, time.minute,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              formatted,
              style: TextStyle(
                color: _departureDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      children: [
        Text('Длительность:', style: AppTextStyles.subtitle),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _durationDays > 1 ? () => setState(() => _durationDays--) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$_durationDays дн.', style: AppTextStyles.title),
        IconButton(
          onPressed: () => setState(() => _durationDays++),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space12),
      child: Text(title, style: AppTextStyles.subtitle),
    );
  }

  Widget _buildChipsList({
    required List<String> items,
    required TextEditingController controller,
    required String hint,
    required void Function(String) onAdd,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
              onDeleted: () => onRemove(entry.key),
            );
          }).toList(),
        ),
        if (items.isNotEmpty) const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    onAdd(v.trim());
                    controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () {
                final v = controller.text.trim();
                if (v.isNotEmpty) {
                  onAdd(v);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddItineraryDay() {
    return Column(
      children: [
        _buildTextField(
          controller: _itineraryDayController,
          label: 'День (номер)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _itineraryDescController,
          label: 'Описание дня',
        ),
        const SizedBox(height: 8),
        JoluButton(
          text: 'Добавить день',
          variant: JoluButtonVariant.outline,
          size: JoluButtonSize.small,
          onPressed: () {
            final day = int.tryParse(_itineraryDayController.text) ?? 0;
            final desc = _itineraryDescController.text.trim();
            if (desc.isNotEmpty) {
              setState(() {
                _itinerary.add(ItineraryDayEntity(day: day, description: desc));
                _itinerary.sort((a, b) => a.day.compareTo(b.day));
              });
              _itineraryDayController.clear();
              _itineraryDescController.clear();
            }
          },
        ),
      ],
    );
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    setState(() => _selectedVideo = video);

    final bytes = await video.readAsBytes();
    if (mounted) {
      context.read<GuideToursCubit>().uploadPromoVideo(bytes, video.name);
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null) {
      JoluSnackbar.show(
        context: context,
        message: 'Выберите дату отправления',
        type: JoluSnackbarType.warning,
      );
      return;
    }

    final entity = CreateTourEntity(
      title: _titleController.text.trim(),
      locationId: _locationIdController.text.trim(),
      departureAt: _departureDate!.toUtc().toIso8601String(),
      durationDays: _durationDays,
      totalSeats: int.parse(_totalSeatsController.text),
      minSeats: int.parse(_minSeatsController.text),
      pricePerSeat: double.parse(_priceController.text),
      includedServices: List.from(_includedServices),
      gearRequirements: List.from(_gearRequirements),
      itinerary: List.from(_itinerary),
    );

    context.read<GuideToursCubit>().createTour(entity);
  }
}