call ndk-build
adb push launch /data/local/tmp/
adb push libsubstrate.so /data/local/tmp/
adb push .\libs\armeabi-v7a\libhook.so /data/local/tmp/
adb shell<launch.txt
