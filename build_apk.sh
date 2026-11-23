#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/nza/.gemini/antigravity/scratch/mobn_blox_legends"
ANDROID_SRC="${PROJECT_DIR}/android-src"
BUILD_DIR="${PROJECT_DIR}/build-apk"
SDK_DIR="/home/nza/Android/Sdk"

PLATFORM_JAR="${SDK_DIR}/platforms/android-35/android.jar"
BUILD_TOOLS="${SDK_DIR}/build-tools/35.0.0"

if [[ ! -f "${PLATFORM_JAR}" || ! -d "${BUILD_TOOLS}" ]]; then
  echo "Installing Android SDK Platform 35 & Build Tools 35.0.0..."
  /home/nza/.local/bin/android sdk install "platforms;android-35" "build-tools;35.0.0"
fi

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/gen" "${BUILD_DIR}/obj" "${BUILD_DIR}/dex" "${BUILD_DIR}/assets/www/src" "${BUILD_DIR}/assets/www/vendor"

cp "${PROJECT_DIR}/index.html" "${BUILD_DIR}/assets/www/"
cp "${PROJECT_DIR}/src/"*.js "${BUILD_DIR}/assets/www/src/"
cp "${PROJECT_DIR}/src/"*.css "${BUILD_DIR}/assets/www/src/"
cp "${PROJECT_DIR}/vendor/three.min.js" "${BUILD_DIR}/assets/www/vendor/"

"${BUILD_TOOLS}/aapt2" compile --dir "${ANDROID_SRC}/res" -o "${BUILD_DIR}/compiled_res.zip"

"${BUILD_TOOLS}/aapt2" link \
  -o "${BUILD_DIR}/unaligned.apk" \
  -I "${PLATFORM_JAR}" \
  --manifest "${ANDROID_SRC}/AndroidManifest.xml" \
  --java "${BUILD_DIR}/gen" \
  -A "${BUILD_DIR}/assets" \
  "${BUILD_DIR}/compiled_res.zip"

javac --release 11 \
  -classpath "${PLATFORM_JAR}" \
  -d "${BUILD_DIR}/obj" \
  "${BUILD_DIR}/gen/com/nzadev/mobn/R.java" \
  "${ANDROID_SRC}/src/com/nzadev/mobn/MainActivity.java"

CLASS_FILES=$(find "${BUILD_DIR}/obj" -name "*.class")
"${BUILD_TOOLS}/d8" --lib "${PLATFORM_JAR}" --output "${BUILD_DIR}/dex" ${CLASS_FILES}

python3 -c '
import zipfile, sys
with zipfile.ZipFile(sys.argv[1], "a", zipfile.ZIP_DEFLATED) as zf:
    zf.write(sys.argv[2], "classes.dex")
' "${BUILD_DIR}/unaligned.apk" "${BUILD_DIR}/dex/classes.dex"

"${BUILD_TOOLS}/zipalign" -f 4 "${BUILD_DIR}/unaligned.apk" "${BUILD_DIR}/aligned.apk"

KEYSTORE="${ANDROID_SRC}/debug.keystore"
if [[ ! -f "${KEYSTORE}" ]]; then
  keytool -genkeypair \
    -v \
    -keystore "${KEYSTORE}" \
    -storepass android \
    -alias androiddebugkey \
    -keypass android \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=NzaDev,OU=GameStudio,O=NzaDev,L=Jakarta,S=DKI,C=ID" >/dev/null 2>&1
fi

FINAL_APK="${PROJECT_DIR}/MOBN-Blox-Legends-v1.0.0.apk"
"${BUILD_TOOLS}/apksigner" sign \
  --ks "${KEYSTORE}" \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "${FINAL_APK}" \
  "${BUILD_DIR}/aligned.apk"

rm -rf "${BUILD_DIR}"
echo "APK successfully built and signed: ${FINAL_APK}"
ls -lh "${FINAL_APK}"

