#! /bin/bash

PROGRAMM="mundanequest"
VERSION="v0.2"

echo "Building:" ${PROGRAMM}

# clean build directory
echo "Cleaning build directories..."
flutter clean

# build for web deployment
echo "Building web version..."
flutter build web --base-href=/mq/ --no-sound-null-safety
cd build
mv web "${PROGRAMM}-web"
zip -r "${PROGRAMM}-${VERSION}-web.zip" "${PROGRAMM}-web"
cd ..
mv "build/${PROGRAMM}-${VERSION}-web.zip" .

# build linux version
echo "Building linux version..."
flutter build linux --no-sound-null-safety
cd build/linux/x64/release
mv bundle "${PROGRAMM}-linux"
zip -r "${PROGRAMM}-${VERSION}-linux.zip" "${PROGRAMM}-linux"
cd ../../../..
mv "build/linux/x64/release/${PROGRAMM}-${VERSION}-linux.zip" .

# build Android version
echo "Building Android version..."
flutter build appbundle --no-sound-null-safety
cp build/app/outputs/bundle/release/app-release.aab ./${PROGRAMM}-${VERSION}-release.aab
flutter build apk --split-per-abi --no-sound-null-safety
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ./${PROGRAMM}-${VERSION}-arm64-v8a-release.apk
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ./${PROGRAMM}-${VERSION}-armeabi-v7a-release.apk
cp build/app/outputs/flutter-apk/app-x86_64-release.apk ./${PROGRAMM}-${VERSION}-x86_64-release.apk
