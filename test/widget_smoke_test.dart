import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:egyptian_race/core/constants.dart';
import 'package:egyptian_race/core/strings.dart';
import 'package:egyptian_race/core/theme.dart';
import 'package:egyptian_race/data/models/user_profile.dart';
import 'package:egyptian_race/presentation/home/home_screen.dart';

void main() {
  setUpAll(() async {
    Hive.init('./test/.hive_widget');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    await Hive.openBox<UserProfile>(GameConstants.boxProfile);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('HomeScreen renders title and the four primary buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: HomeScreen(),
          ),
          theme: AppTheme.light(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.playNow), findsOneWidget);
    expect(find.text(AppStrings.tutorial), findsOneWidget);
    expect(find.text(AppStrings.store), findsOneWidget);
    expect(find.text(AppStrings.myAchievements), findsOneWidget);
  });
}
