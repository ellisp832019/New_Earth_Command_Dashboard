#include "windows_voice_speech_channel.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <cmath>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include <sapi.h>
#include <wrl/client.h>

namespace {

constexpr char kChannelName[] = "new_earth/windows_voice_speech";

std::mutex g_voice_mutex;
Microsoft::WRL::ComPtr<ISpVoice> g_voice;

struct ComApartment {
  ComApartment() : hr(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED)) {}

  ~ComApartment() {
    if (SUCCEEDED(hr)) {
      CoUninitialize();
    }
  }

  bool is_ready() const {
    return SUCCEEDED(hr) || hr == RPC_E_CHANGED_MODE;
  }

  HRESULT hr;
};

std::wstring Utf8ToWide(const std::string& text) {
  if (text.empty()) {
    return L"";
  }

  const int required = MultiByteToWideChar(
      CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()), nullptr, 0);
  if (required <= 0) {
    return L"";
  }

  std::wstring result(required, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()),
                      result.data(), required);
  return result;
}

std::string WideToUtf8(const std::wstring& text) {
  if (text.empty()) {
    return "";
  }

  const int required = WideCharToMultiByte(
      CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()), nullptr, 0,
      nullptr, nullptr);
  if (required <= 0) {
    return "";
  }

  std::string result(required, '\0');
  WideCharToMultiByte(CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()),
                      result.data(), required, nullptr, nullptr);
  return result;
}

std::string ReadTokenString(ISpObjectToken* token, const wchar_t* key) {
  LPWSTR raw_value = nullptr;
  if (FAILED(token->GetStringValue(key, &raw_value)) || raw_value == nullptr) {
    return "";
  }

  std::wstring value(raw_value);
  ::CoTaskMemFree(raw_value);
  return WideToUtf8(value);
}

std::string ReadTokenId(ISpObjectToken* token) {
  LPWSTR raw_value = nullptr;
  if (FAILED(token->GetId(&raw_value)) || raw_value == nullptr) {
    return "";
  }

  std::wstring value(raw_value);
  ::CoTaskMemFree(raw_value);
  return WideToUtf8(value);
}

std::string ReadTokenDisplayName(ISpObjectToken* token) {
  LPWSTR raw_value = nullptr;
  if (FAILED(token->GetStringValue(nullptr, &raw_value)) || raw_value == nullptr) {
    return "";
  }

  std::wstring value(raw_value);
  ::CoTaskMemFree(raw_value);
  return WideToUtf8(value);
}

std::string ReadVoiceLocale(ISpObjectToken* token) {
  const std::string language = ReadTokenString(token, L"Language");
  if (language.empty()) {
    return "";
  }

  const std::string first_code = language.substr(0, language.find(';'));
  const auto language_id = static_cast<LANGID>(std::wcstoul(
      Utf8ToWide(first_code).c_str(), nullptr, 16));
  wchar_t locale_name[LOCALE_NAME_MAX_LENGTH] = {};
  if (LCIDToLocaleName(MAKELCID(language_id, SORT_DEFAULT), locale_name,
                       LOCALE_NAME_MAX_LENGTH, 0) > 0) {
    return WideToUtf8(locale_name);
  }

  return language;
}

bool EnsureVoice() {
  ComApartment com;
  if (!com.is_ready()) {
    return false;
  }

  if (g_voice) {
    return true;
  }

  const HRESULT hr = CoCreateInstance(
      CLSID_SpVoice, nullptr, CLSCTX_ALL, IID_ISpVoice,
      reinterpret_cast<void**>(g_voice.ReleaseAndGetAddressOf()));
  return SUCCEEDED(hr) && g_voice;
}

Microsoft::WRL::ComPtr<IEnumSpObjectTokens> EnumerateVoiceTokens() {
  ComApartment com;
  if (!com.is_ready()) {
    return nullptr;
  }

  Microsoft::WRL::ComPtr<ISpObjectTokenCategory> category;
  const HRESULT hr = CoCreateInstance(
      CLSID_SpObjectTokenCategory, nullptr, CLSCTX_ALL,
      IID_ISpObjectTokenCategory,
      reinterpret_cast<void**>(category.ReleaseAndGetAddressOf()));
  if (FAILED(hr) || !category) {
    return nullptr;
  }

  if (FAILED(category->SetId(SPCAT_VOICES, FALSE))) {
    return nullptr;
  }

  Microsoft::WRL::ComPtr<IEnumSpObjectTokens> enumerator;
  if (FAILED(category->EnumTokens(nullptr, nullptr,
                                  enumerator.ReleaseAndGetAddressOf())) ||
      !enumerator) {
    return nullptr;
  }

  return enumerator;
}

Microsoft::WRL::ComPtr<ISpObjectToken> FindVoiceTokenById(
    const std::string& identifier) {
  Microsoft::WRL::ComPtr<IEnumSpObjectTokens> enumerator =
      EnumerateVoiceTokens();
  if (!enumerator) {
    return nullptr;
  }

  ULONG fetched = 0;
  Microsoft::WRL::ComPtr<ISpObjectToken> token;
  while (enumerator->Next(1, token.ReleaseAndGetAddressOf(), &fetched) == S_OK &&
         fetched == 1) {
    if (ReadTokenId(token.Get()) == identifier) {
      return token;
    }
    token.Reset();
  }

  return nullptr;
}

flutter::EncodableMap BuildVoiceMap(ISpObjectToken* token) {
  flutter::EncodableMap map;
  const std::string identifier = ReadTokenId(token);
  const std::string name = ReadTokenDisplayName(token);
  const std::string fallback_name = ReadTokenString(token, L"Name");
  const std::string gender = ReadTokenString(token, L"Gender");
  const std::string locale = ReadVoiceLocale(token);

  map[flutter::EncodableValue("identifier")] = flutter::EncodableValue(identifier);
  map[flutter::EncodableValue("name")] = flutter::EncodableValue(
      !name.empty() ? name : (!fallback_name.empty() ? fallback_name : identifier));
  map[flutter::EncodableValue("locale")] = flutter::EncodableValue(
      locale.empty() ? "unknown" : locale);
  if (!gender.empty()) {
    map[flutter::EncodableValue("gender")] = flutter::EncodableValue(gender);
  }

  return map;
}

bool SpeakText(
    const std::string& text,
    const std::string& identifier,
    double rate,
    double pitch) {
  ComApartment com;
  if (!com.is_ready()) {
    return false;
  }

  if (!EnsureVoice()) {
    return false;
  }

  std::lock_guard<std::mutex> lock(g_voice_mutex);

  if (!identifier.empty()) {
    const Microsoft::WRL::ComPtr<ISpObjectToken> token =
        FindVoiceTokenById(identifier);
    if (token) {
      g_voice->SetVoice(token.Get());
    }
  }

  const auto rate_value = static_cast<long>(std::lround((rate - 0.5) * 10.0));
  g_voice->SetRate(rate_value);

  // SAPI does not expose a simple per-voice pitch slider. We keep the
  // preference in the app, and can map it more precisely later if needed.
  (void)pitch;

  const std::wstring wide_text = Utf8ToWide(text);
  return SUCCEEDED(
      g_voice->Speak(wide_text.c_str(), SPF_PURGEBEFORESPEAK, nullptr));
}

bool StopSpeaking() {
  ComApartment com;
  if (!com.is_ready()) {
    return false;
  }

  if (!EnsureVoice()) {
    return false;
  }

  std::lock_guard<std::mutex> lock(g_voice_mutex);
  return SUCCEEDED(
      g_voice->Speak(L"", SPF_PURGEBEFORESPEAK, nullptr));
}

}  // namespace

void RegisterWindowsVoiceSpeechChannel(flutter::FlutterEngine* engine) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          engine->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler([engine](const auto& call, auto result) {
    const std::string& method = call.method_name();

    if (method == "listVoices") {
      if (!EnsureVoice()) {
        result->Success(flutter::EncodableValue(flutter::EncodableList{}));
        return;
      }

      std::vector<flutter::EncodableValue> voices;
      Microsoft::WRL::ComPtr<IEnumSpObjectTokens> enumerator =
          EnumerateVoiceTokens();
      if (enumerator) {
        ULONG fetched = 0;
        Microsoft::WRL::ComPtr<ISpObjectToken> token;
        while (enumerator->Next(1, token.ReleaseAndGetAddressOf(), &fetched) ==
                   S_OK &&
               fetched == 1) {
          voices.push_back(
              flutter::EncodableValue(BuildVoiceMap(token.Get())));
          token.Reset();
        }
      }

      result->Success(flutter::EncodableValue(std::move(voices)));
      return;
    }

    if (method == "speak") {
      const auto* arguments = std::get_if<flutter::EncodableMap>(
          call.arguments());
      if (arguments == nullptr) {
        result->Error("invalid_arguments", "Missing voice payload.");
        return;
      }

      const auto text_it = arguments->find(flutter::EncodableValue("text"));
      const auto rate_it = arguments->find(flutter::EncodableValue("rate"));
      const auto pitch_it = arguments->find(flutter::EncodableValue("pitch"));
      const auto voice_it = arguments->find(flutter::EncodableValue("voice"));

      const std::string text = text_it != arguments->end()
                                   ? std::get<std::string>(text_it->second)
                                   : "";
      const double rate = rate_it != arguments->end()
                              ? std::get<double>(rate_it->second)
                              : 0.5;
      const double pitch = pitch_it != arguments->end()
                               ? std::get<double>(pitch_it->second)
                               : 1.0;
      std::string identifier;
      if (voice_it != arguments->end()) {
        if (const auto* voice_map =
                std::get_if<flutter::EncodableMap>(&voice_it->second)) {
          const auto id_it =
              voice_map->find(flutter::EncodableValue("identifier"));
          if (id_it != voice_map->end()) {
            identifier = std::get<std::string>(id_it->second);
          }
        }
      }

      result->Success(flutter::EncodableValue(
          SpeakText(text, identifier, rate, pitch)));
      return;
    }

    if (method == "stopSpeaking") {
      result->Success(flutter::EncodableValue(StopSpeaking()));
      return;
    }

    result->NotImplemented();
  });

  static std::vector<
      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>>
      channels;
  channels.push_back(std::move(channel));
}
