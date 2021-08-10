# Mundane Quest

Mundane Quest is a simple question and answer game, not unlike Trivial Pursuit.

## Building

This project can be build with Android Studio. Alternatively you can use the
command line:

    flutter build linux --no-sound-null-safety
    flutter build web --base-href=/mq/ --no-sound-null-safety
    flutter build apk --split-per-abi --no-sound-null-safety

Or just use the build script, that creates the web, linux and Android version:

    ./build_release.sh

## Dependencies

All trivial questions are coming from the OpenTrivia Database
(https://opentdb.com/). An API description can be found under
https://opentdb.com/api_config.php.

* https://pub.dev/packages/http
* https://pub.dev/packages/html_unescape
* https://pub.dev/packages/shared_preferences
* https://pub.dev/packages/flutter_settings_screens
* https://pub.dev/packages/animated_flip_counter
* https://pub.dev/packages/just_audio
* https://pub.dev/packages/desktop_window
