#ifndef RUNNER_WINDOWS_VOICE_TYPING_CHANNEL_H_
#define RUNNER_WINDOWS_VOICE_TYPING_CHANNEL_H_

namespace flutter {
class FlutterEngine;
}

class FlutterWindow;

void RegisterWindowsVoiceTypingChannel(
    flutter::FlutterEngine* engine,
    FlutterWindow* window);

#endif  // RUNNER_WINDOWS_VOICE_TYPING_CHANNEL_H_
