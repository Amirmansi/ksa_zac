#!/usr/bin/env bash
# Egyptian Race - Phase 1 setup script
# Usage: ./setup.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 1. Check / install Flutter
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ Flutter غير مثبت."
  echo ""
  if command -v brew >/dev/null 2>&1; then
    echo "تثبيت Flutter عبر Homebrew (هياخد دقايق وحوالي 2GB):"
    echo "  brew install --cask flutter"
    echo ""
    read -rp "تحب أنفذها دلوقتي؟ [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      brew install --cask flutter
    else
      echo "اعمله لما تكون جاهز ثم اعد تشغيل ./setup.sh"
      exit 1
    fi
  else
    echo "حمّل Flutter SDK من: https://docs.flutter.dev/get-started/install/macos"
    echo "أو ثبّت Homebrew الأول من: https://brew.sh"
    exit 1
  fi
fi

echo "✅ Flutter:"
flutter --version | head -1

# 2. Generate android/ folder if missing (preserves our lib/, assets/, pubspec.yaml).
if [ ! -d "$ROOT/android" ]; then
  echo "🔨 إنشاء مجلد android (Flutter create)…"
  flutter create \
    --org com.amir.egyptianrace \
    --project-name egyptian_race \
    --platforms=android \
    --description "السباق المصري" \
    .
fi

# 3. Patch minSdk = 24 (Hive + flame_audio happy)
GRADLE="$ROOT/android/app/build.gradle"
if [ -f "$GRADLE" ] && grep -q "minSdkVersion " "$GRADLE"; then
  echo "🔧 تعديل minSdkVersion → 24"
  sed -i.bak -E 's/minSdkVersion ([a-zA-Z0-9.]+)/minSdkVersion 24/' "$GRADLE" || true
  rm -f "$GRADLE.bak"
fi
GRADLE_KTS="$ROOT/android/app/build.gradle.kts"
if [ -f "$GRADLE_KTS" ] && grep -q "minSdk = " "$GRADLE_KTS"; then
  echo "🔧 تعديل minSdk → 24 (kts)"
  sed -i.bak -E 's/minSdk = [a-zA-Z0-9.]+/minSdk = 24/' "$GRADLE_KTS" || true
  rm -f "$GRADLE_KTS.bak"
fi

# 4. Pull dependencies
echo "📦 flutter pub get"
flutter pub get

# 5. Doctor (informational)
echo ""
echo "🩺 flutter doctor (لمراجعتك):"
flutter doctor -v | head -30 || true

cat <<'EOF'

════════════════════════════════════════════
✅ Phase 1 جاهز للتشغيل!

الخطوات الجاية:
  1. شبك موبايل أندرويد بـ USB أو شغّل Emulator.
  2. شغّل اللعبة:
       flutter run

  3. اختبارات Phase 1:
       flutter test

  4. الأصوات (اختياري دلوقتي):
       شوف assets/audio/README.md للقايمة وروابط التحميل.

════════════════════════════════════════════
EOF
