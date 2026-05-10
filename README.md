# 🐫 السباق المصري — Egyptian Race v2.0

لعبة سباق طولية مصرية أصلية، مجانية ١٠٠٪، أوفلاين، أندرويد فقط.

| الإصدار | الحالة | التكنولوجيا |
|---|---|---|
| 1.0.0+1 | كامل ✅ — كل الـ 5 phases | Flutter 3.24+, Flame 1.18+, Riverpod 2, Hive, GoogleFonts/Cairo |

## 🚀 التشغيل السريع

```bash
# تشغيل الـ app على موبايل/Emulator
./setup.sh           # يثبّت Flutter لو مش موجود + يعمل pub get
flutter run          # شغّل على موبايل/Emulator
flutter test         # اختبارات

# بناء APK جاهز للتثبيت (release signed)
./build_apk.sh       # يطلع: dist/egyptian_race-1.0.0.apk
```

## 📦 ما تم في Phase 1

- ✅ بنية مشروع كاملة (clean architecture)
- ✅ Theme + Cairo font + RTL أصلي + لوحة ألوان مصرية دافية
- ✅ Hive + UserProfile (عملات، إنجازات، إعدادات، استمرارية يومية)
- ✅ AudioManager + Haptic helper (قوي ضد فقدان الأصول)
- ✅ Splash + Home (مع شارة العملات + زر المكافأة اليومية)
- ✅ Settings كاملة (sound/music/haptics/volume/reset)
- ✅ Daily Reward dialog مع streak ٧ أيام
- ✅ Stubs لباقي الشاشات (setup, game, store, achievements, tutorial)
- ✅ go_router مع كل المسارات
- ✅ اختبارات وحدة (Hive + UserProfile + daily reward logic)

## 🗂 هيكل المشروع

```
lib/
├── main.dart                  # نقطة البداية + Hive init
├── app.dart                   # MaterialApp.router + RTL forcing
├── core/
│   ├── colors.dart            # لوحة ألوان مصرية كاملة
│   ├── typography.dart        # Cairo TextStyles
│   ├── theme.dart             # ThemeData light
│   ├── constants.dart         # GameConstants (30 خلية، الجوائز، ...)
│   ├── strings.dart           # كل النصوص العربية
│   └── routes.dart            # GoRouter
├── data/
│   ├── models/
│   │   ├── user_profile.dart   # @HiveType(typeId: 0)
│   │   └── user_profile.g.dart # adapter (مكتوب يدوياً)
│   └── repositories/
│       └── profile_repo.dart   # Riverpod Notifier
├── utils/
│   ├── audio_manager.dart      # flame_audio wrapper
│   └── haptic.dart             # vibration + HapticFeedback
└── presentation/
    ├── splash/splash_screen.dart
    ├── home/
    │   ├── home_screen.dart
    │   └── widgets/
    │       ├── coins_badge.dart
    │       ├── menu_button.dart
    │       └── daily_reward_dialog.dart
    ├── setup/player_setup_screen.dart   (stub)
    ├── game/game_screen.dart            (stub)
    ├── store/store_screen.dart          (stub)
    ├── achievements/achievements_screen.dart
    ├── settings/settings_screen.dart    (✅ كاملة)
    └── tutorial/tutorial_screen.dart    (stub)
assets/
├── audio/
│   ├── sfx/        ← دلوّق فاضي. شوف assets/audio/README.md
│   └── music/      ← دلوّق فاضي
├── images/         ← دلوّق فاضي. شخصيات وأيقونات لاحقاً
└── fonts/          ← Cairo بيجي من google_fonts (مش لازم محلي)
test/
└── profile_repo_test.dart      # اختبارات Hive + daily reward
```

## ✅ Validation Checklist (Phase 1)

| الاختبار | النتيجة المتوقعة |
|---|---|
| `flutter run` | شاشة splash → home في < 3 ثواني |
| الضغط على ⚙️ | يفتح Settings و التعديلات تتحفظ |
| الضغط على "العب الآن" | يفتح stub الـ setup |
| الضغط على "تدريب" / "المتجر" / "إنجازاتي" | تفتح stubs |
| المكافأة اليومية | تظهر مرة وحدة، +50 عملة، الزر يختفي |
| إعادة فتح اللعبة | كل البيانات محفوظة (العملات، الإعدادات) |
| `flutter test` | كل الـ 6 اختبارات تنجح |
| `flutter analyze` | بدون أخطاء |

## 🎮 الـ Phases الجاية

| Phase | المحتوى |
|---|---|
| 2 | Game canvas (Flame): رسم الـ 30 خلية، النرد، الـ tokens |
| 3 | Game logic: حركة، اصطدام، أسئلة، AI، Power Bar |
| 4 | Setup flow كامل + Tutorial + Store + Achievements |
| 5 | Polish: الأصوات الحقيقية، الأنيميشن، Build & Sign |

## 🤔 قرارات معمارية

1. **Hive بدون build_runner** — كتبنا adapter يدوي للـ UserProfile عشان المشروع يشتغل من أول `flutter pub get` بدون codegen step. يقدر يتولّد تلقائياً لاحقاً لما تضيف models جديدة بـ `dart run build_runner build`.

2. **Riverpod 2 Notifier** — مش StateNotifier القديم. `state` mutable داخل Notifier لكن `ref.notifyListeners()` بتضمن الـ widgets ترصد التغيير.

3. **AudioManager resilient** — لو الأصوات مش موجودة، اللعبة بتشتغل عادي وبتطبع warning في debug فقط. ده مهم عشان نقدر نختبر Phase 2-4 قبل ما ننزّل الأصوات.

4. **RTL في كل الشاشات** — Locale ar_EG + Directionality.rtl في الـ MaterialApp builder.

5. **Cairo من google_fonts** — مفيش حاجة نضيفها يدوي للـ assets.

6. **stubs بدل صفحات فاضية** — كل stub بيقول صراحة "Phase X" عشان مفيش حد يحتار.

## 📝 ملاحظات

- لو شغلت Phase 2 وغيرت `UserProfile`، احذف `user_profile.g.dart` وشغّل `dart run build_runner build --delete-conflicting-outputs`.
- الـ Cairo font بييجي online لما يبدأ التطبيق، فأول مرة يحتاج نت. لو حابب offline فقط، حمّل `Cairo-Regular.ttf` و `Cairo-Bold.ttf` لـ `assets/fonts/` وعدّل `pubspec.yaml`.
