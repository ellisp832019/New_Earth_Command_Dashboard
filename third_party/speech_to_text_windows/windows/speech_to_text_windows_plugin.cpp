#include "speech_to_text_windows_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

namespace speech_to_text_windows {

void SpeechToTextWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "speech_to_text_windows",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<SpeechToTextWindowsPlugin>();
  plugin->m_channel = std::move(channel);

  plugin->m_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

SpeechToTextWindowsPlugin::SpeechToTextWindowsPlugin()
    : m_cpRecognizer(nullptr),
      m_cpRecoContext(nullptr),
      m_cpRecoGrammar(nullptr),
      m_cpAudio(nullptr),
      m_initialized(false),
      m_listening(false) {}

SpeechToTextWindowsPlugin::~SpeechToTextWindowsPlugin() = default;

void SpeechToTextWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method_name = method_call.method_name();

  if (method_name == "hasPermission") {
    result->Success(flutter::EncodableValue(false));
  } else if (method_name == "initialize") {
    Initialize(method_call, std::move(result));
  } else if (method_name == "listen") {
    Listen(method_call, std::move(result));
  } else if (method_name == "stop") {
    Stop(std::move(result));
  } else if (method_name == "cancel") {
    Cancel(std::move(result));
  } else if (method_name == "locales") {
    GetLocales(std::move(result));
  } else {
    result->NotImplemented();
  }
}

void SpeechToTextWindowsPlugin::Initialize(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  m_initialized = false;
  result->Success(flutter::EncodableValue(false));
}

void SpeechToTextWindowsPlugin::Listen(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->Success(flutter::EncodableValue(false));
}

void SpeechToTextWindowsPlugin::Stop(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  m_listening = false;
  if (result) {
    result->Success(flutter::EncodableValue(nullptr));
  }
}

void SpeechToTextWindowsPlugin::Cancel(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  Stop(std::move(result));
}

void SpeechToTextWindowsPlugin::GetLocales(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->Success(flutter::EncodableValue(flutter::EncodableList()));
}

void SpeechToTextWindowsPlugin::SendTextRecognition(const std::string& text,
                                                    bool is_final) {}

void SpeechToTextWindowsPlugin::SendError(const std::string& error) {}

void SpeechToTextWindowsPlugin::SendStatus(const std::string& status) {}

}  // namespace speech_to_text_windows

extern "C" __declspec(dllexport) void
SpeechToTextWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  speech_to_text_windows::SpeechToTextWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
