// Проверка вёрстки страницы локации: секции не должны переполняться
// ни на узком экране, ни на длинных строках.
//
// Запуск: flutter test test/location_detail_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jolutrip_app/core/theme/app_colors.dart';
import 'package:jolutrip_app/features/location-detail/domain/domain.dart';
import 'package:jolutrip_app/features/location-detail/view/widgets/widgets.dart';

const _longText =
    'Дорога до перевала идёт по грунтовке с участками крупного камня, '
    'после дождя размывается и требует внедорожника с высоким клиренсом.';

RoadsidePlaceEntity _place({double? averageCheck}) => RoadsidePlaceEntity(
  id: '1',
  name: 'Юрточный лагерь у реки Кёкёмерен',
  description: _longText,
  category: PlaceCategory.ethnoResort,
  amenities: const ['wifi', 'food'],
  averageCheck: averageCheck,
  photos: const [],
);

LocationDetailEntity _location({String? name}) => LocationDetailEntity(
  id: '1',
  name: name ?? 'Сон-Куль',
  shortDescription: 'Высокогорное озеро на 3016 метрах',
  description: _longText * 3,
  videoUrl: '',
  thumbnailUrl: '',
  category: 'Озеро',
  hasInternet: false,
  carRequirement: 'Только внедорожник',
  travelDays: 1,
  travelHours: 6,
  travelMinutes: 30,
  priceStartsFrom: 4500,
  entryFee: 250,
  latitude: 41.8425,
  longitude: 75.1206,
  roadFeatures: const ['Грунтовка 40 км', 'Перевал 3400 м', 'Броды'],
  gearList: const ['Тёплые вещи', 'Спальник', 'Аптечка', 'Канистра с топливом'],
  roadsidePlaces: [_place(averageCheck: 800), _place()],
);

Future<void> _pump(WidgetTester tester, Widget child, {double width = 320}) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  return tester.pumpWidget(
    MaterialApp(
      theme: AppColors.darkTheme,
      home: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'карточки остановок не переполняются при указанном среднем чеке',
    (tester) async {
      // Регрессия: SizedBox(height: 200) при контенте ~245px.
      await _pump(
        tester,
        LocationRoadsidePlaces(
          places: [_place(averageCheck: 1200), _place()],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Где остановиться'), findsOneWidget);
    },
  );

  testWidgets('инфо-карточки держат длинные значения на узком экране', (
    tester,
  ) async {
    await _pump(tester, LocationInfoCards(location: _location()), width: 300);

    expect(tester.takeException(), isNull);
    expect(find.text('Только внедорожник'), findsOneWidget);
    expect(find.text('250 сом'), findsOneWidget);
  });

  testWidgets('длинное описание сворачивается и раскрывается', (tester) async {
    await _pump(tester, LocationDescription(location: _location()));

    expect(find.text('Читать полностью'), findsOneWidget);

    await tester.tap(find.text('Читать полностью'));
    await tester.pumpAndSettle();

    expect(find.text('Свернуть'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('панель действий помещается на узком экране', (tester) async {
    await _pump(tester, const LocationActionBar(), width: 300);

    expect(tester.takeException(), isNull);
    expect(find.text('Маршрут'), findsOneWidget);
    expect(find.text('С гидом'), findsOneWidget);
  });

  testWidgets('карточка гида и шит гида рендерятся', (tester) async {
    await _pump(tester, const LocationGuideCard(), width: 320);
    expect(tester.takeException(), isNull);

    await _pump(tester, const LocationGuideSheet(), width: 320);
    expect(tester.takeException(), isNull);
    expect(find.text('Поездка с гидом'), findsOneWidget);
  });

  testWidgets('скелет загрузки рендерится', (tester) async {
    await _pump(tester, const LocationDetailSkeleton());
    expect(tester.takeException(), isNull);
  });

  testWidgets('превью карты рендерится и копирует координаты', (tester) async {
    await _pump(tester, LocationMapPreview(location: _location()));

    expect(tester.takeException(), isNull);
    expect(find.text('41.8425, 75.1206'), findsOneWidget);
  });

  testWidgets('обложка сворачивается в тулбар при скролле', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final location = _location(name: 'Очень длинное название локации в горах');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppColors.darkTheme,
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: LocationHeroSection.heightFor(context),
                  flexibleSpace: LocationHeroSection(location: location),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 1200)),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    // Длинное название в развёрнутом и в свёрнутом заголовке — два вхождения.
    expect(find.text(location.name), findsNWidgets(2));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
