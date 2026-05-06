#include "windows_voice_typing_channel.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <vector>

#include "flutter_window.h"

namespace {

constexpr char kChannelName[] = "new_earth/windows_voice_typing";

void SendKeyInput(WORD key, DWORD flags = 0) {
  INPUT input = {};
  input.type = INPUT_KEYBOARD;
  input.ki.wVk = key;
  input.ki.dwFlags = flags;
  SendInput(1, &input, sizeof(INPUT));
}

bool SendVoiceTypingShortcut(FlutterWindow* window) {
  const HWND window_handle = window->GetHandle();
  const HWND content_handle = window->GetChildContentHandle();

  if (window_handle == nullptr || content_handle == nullptr) {
    return false;
  }

  SetForegroundWindow(window_handle);
  SetActiveWindow(window_handle);
  SetFocus(content_handle);
  Sleep(80);

  SendKeyInput(VK_LWIN);
  SendKeyInput('H');
  SendKeyInput('H', KEYEVENTF_KEYUP);
  SendKeyInput(VK_LWIN, KEYEVENTF_KEYUP);

  return true;
}

bool SendEscapeToCloseVoiceTyping(FlutterWindow* window) {
  const HWND window_handle = window->GetHandle();
  const HWND content_handle = window->GetChildContentHandle();

  if (window_handle == nullptr || content_handle == nullptr) {
    return false;
  }

  SetForegroundWindow(window_handle);
  SetActiveWindow(window_handle);
  SetFocus(content_handle);
  Sleep(40);

  SendKeyInput(VK_ESCAPE);
  SendKeyInput(VK_ESCAPE, KEYEVENTF_KEYUP);

  return true;
}

}  // namespace

void RegisterWindowsVoiceTypingChannel(
    flutter::FlutterEngine* engine,
    FlutterWindow* window) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(), kChannelName,
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [window](const auto& call, auto result) {
        const std::string& method = call.method_name();

        if (method == "startVoiceTyping") {
          result->Success(
              flutter::EncodableValue(SendVoiceTypingShortcut(window)));
          return;
        }

        if (method == "stopVoiceTyping" || method == "cancelVoiceTyping") {
          result->Success(
              flutter::EncodableValue(SendEscapeToCloseVoiceTyping(window)));
          return;
        }

        result->NotImplemented();
      });

  static std::vector<
      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>>
      channels;
  channels.push_back(std::move(channel));
}
