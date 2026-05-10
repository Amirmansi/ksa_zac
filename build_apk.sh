#!/usr/bin/env bash
# End-to-end Android build pipeline.
# Usage: ./build_apk.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

log() { echo ""; echo "═══ $* ═══"; }

# ---------- 0. Tool checks ----------
log "0/8 فحص الأدوات"

# OpenJDK 17 from brew is keg-only — wire it onto PATH and JAVA_HOME.
if [ -x /opt/homebrew/opt/openjdk@17/bin/java ]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
  export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
fi

command -v flutter >/dev/null || { echo "flutter غير مثبت"; exit 1; }
command -v java >/dev/null || { echo "java غير متاح"; exit 1; }
command -v keytool >/dev/null || { echo "keytool غير متاح"; exit 1; }

flutter --version | head -1
java -version 2>&1 | head -1
echo "JAVA_HOME=${JAVA_HOME:-(default)}"

# Detect Android SDK location.
if [ -z "${ANDROID_HOME:-}" ]; then
  for cand in \
    "/opt/homebrew/share/android-commandlinetools" \
    "/usr/local/share/android-commandlinetools" \
    "$HOME/Library/Android/sdk"; do
    if [ -d "$cand" ]; then
      export ANDROID_HOME="$cand"
      break
    fi
  done
fi
[ -z "${ANDROID_HOME:-}" ] && { echo "ANDROID_HOME مش مظبوط"; exit 1; }
echo "ANDROID_HOME=$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Tell Flutter where the SDK is.
flutter config --android-sdk "$ANDROID_HOME" >/dev/null

# ---------- 1. Accept Android licenses ----------
log "1/8 قبول رخص Android (تلقائي)"
yes | sdkmanager --licenses >/dev/null 2>&1 || true
# Required components for build (silent).
yes | sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null 2>&1 || true

# ---------- 2. flutter create (only if android folder missing) ----------
log "2/8 توليد مجلد android لو ناقص"
if [ ! -d "$ROOT/android" ]; then
  flutter create \
    --org com.amir.egyptianrace \
    --project-name egyptian_race \
    --platforms=android \
    --description "Egyptian Race" \
    .
fi

# Patch min/target SDK for Hive + flame_audio (>=24).
GRADLE_KTS="$ROOT/android/app/build.gradle.kts"
GRADLE="$ROOT/android/app/build.gradle"
if [ -f "$GRADLE_KTS" ]; then
  sed -i.bak -E 's/minSdk *= *flutter\.minSdkVersion/minSdk = 24/' "$GRADLE_KTS"
  sed -i.bak -E 's/minSdk *= *[0-9]+/minSdk = 24/' "$GRADLE_KTS"
  rm -f "$GRADLE_KTS.bak"
elif [ -f "$GRADLE" ]; then
  sed -i.bak -E 's/minSdkVersion [a-zA-Z0-9.]+/minSdkVersion 24/' "$GRADLE"
  rm -f "$GRADLE.bak"
fi

# ---------- 3. Generate release keystore ----------
log "3/8 توليد keystore (مرة واحدة)"
KEYSTORE="$ROOT/android/app/release.jks"
KEY_PROPS="$ROOT/android/key.properties"
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkey -v \
    -keystore "$KEYSTORE" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias egyptian-race \
    -storepass eg-race-2026 \
    -keypass eg-race-2026 \
    -dname "CN=Egyptian Race, OU=Game, O=Amir, L=Cairo, ST=Cairo, C=EG" >/dev/null
fi
cat > "$KEY_PROPS" <<EOF
storePassword=eg-race-2026
keyPassword=eg-race-2026
keyAlias=egyptian-race
storeFile=release.jks
EOF
echo "keystore: $KEYSTORE"

# ---------- 4. Wire signing into build.gradle.kts ----------
log "4/8 ضبط signing في build.gradle.kts"
if [ -f "$GRADLE_KTS" ] && ! grep -q 'signingConfigs\.getByName("release")' "$GRADLE_KTS"; then
  python3 "$ROOT/.tools/patch_gradle.py" "$GRADLE_KTS"
fi

# ---------- 5. flutter pub get ----------
log "5/8 flutter pub get"
flutter pub get

# ---------- 6. analyze ----------
log "6/8 flutter analyze"
flutter analyze || echo "(analyze warnings — كمل للبناء)"

# ---------- 7. build release apk ----------
log "7/8 flutter build apk --release"
flutter build apk --release

# ---------- 8. copy to dist/ ----------
log "8/8 نسخ APK لـ dist/"
mkdir -p "$ROOT/dist"
cp "$ROOT/build/app/outputs/flutter-apk/app-release.apk" "$ROOT/dist/egyptian_race-1.0.0.apk"

ls -lh "$ROOT/dist/"
echo ""
echo "✅ تم! الـ APK في: $ROOT/dist/egyptian_race-1.0.0.apk"
echo "   نقله للموبايل وثبّته (لازم تفعل Install from Unknown Sources)."
