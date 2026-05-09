#include "windows_audio_gate_channel.h"

#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <mmdeviceapi.h>
#include <windows.h>

#include <algorithm>
#include <cctype>
#include <memory>
#include <string>
#include <vector>

#include <Functiondiscoverykeys_devpkey.h>
#include <propsys.h>
#include <propvarutil.h>
#include <wrl/client.h>

namespace {

constexpr char kChannelName[] = "new_earth/windows_audio_gate";

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

std::string Utf16PointerToUtf8(LPWSTR text) {
  if (text == nullptr) {
    return "";
  }

  std::wstring value(text);
  return WideToUtf8(value);
}

std::string GetFriendlyName(IMMDevice* device) {
  Microsoft::WRL::ComPtr<IPropertyStore> properties;
  if (FAILED(device->OpenPropertyStore(STGM_READ,
                                       properties.ReleaseAndGetAddressOf())) ||
      !properties) {
    return "";
  }

  PROPVARIANT value;
  PropVariantInit(&value);
  const HRESULT hr = properties->GetValue(PKEY_Device_FriendlyName, &value);
  if (FAILED(hr)) {
    PropVariantClear(&value);
    return "";
  }

  std::string friendly_name;
  if (value.vt == VT_LPWSTR && value.pwszVal != nullptr) {
    friendly_name = WideToUtf8(value.pwszVal);
  }

  PropVariantClear(&value);
  return friendly_name;
}

std::string GetDeviceId(IMMDevice* device) {
  LPWSTR raw_id = nullptr;
  if (FAILED(device->GetId(&raw_id)) || raw_id == nullptr) {
    return "";
  }

  std::string id = Utf16PointerToUtf8(raw_id);
  ::CoTaskMemFree(raw_id);
  return id;
}

std::string ToLowerUtf8(const std::string& text) {
  std::string result = text;
  std::transform(result.begin(), result.end(), result.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return result;
}

bool IsHeadsetLike(const std::string& name, const std::string& identifier) {
  const std::string lower_name = ToLowerUtf8(name);
  const std::string lower_identifier = ToLowerUtf8(identifier);
  const std::vector<std::string> keywords = {
      "headset", "bluetooth", "hands-free", "hands free", "airpods",
      "earbud",  "earbuds",    "wireless",   "bthenum",    "headphones",
  };

  for (const auto& keyword : keywords) {
    if (lower_name.find(keyword) != std::string::npos ||
        lower_identifier.find(keyword) != std::string::npos) {
      return true;
    }
  }

  return false;
}

flutter::EncodableMap BuildDeviceMap(const std::string& name,
                                     const std::string& identifier) {
  flutter::EncodableMap map;
  map[flutter::EncodableValue("name")] = flutter::EncodableValue(name);
  map[flutter::EncodableValue("identifier")] = flutter::EncodableValue(identifier);
  map[flutter::EncodableValue("isHeadsetLike")] =
      flutter::EncodableValue(IsHeadsetLike(name, identifier));
  return map;
}

std::vector<flutter::EncodableValue> ListCaptureDevices() {
  Microsoft::WRL::ComPtr<IMMDeviceEnumerator> enumerator;
  const HRESULT enum_hr = CoCreateInstance(
      __uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
      __uuidof(IMMDeviceEnumerator),
      reinterpret_cast<void**>(enumerator.ReleaseAndGetAddressOf()));
  if (FAILED(enum_hr) || !enumerator) {
    return {};
  }

  Microsoft::WRL::ComPtr<IMMDeviceCollection> collection;
  const HRESULT collection_hr =
      enumerator->EnumAudioEndpoints(eCapture, DEVICE_STATE_ACTIVE,
                                     collection.ReleaseAndGetAddressOf());
  if (FAILED(collection_hr) || !collection) {
    return {};
  }

  UINT count = 0;
  if (FAILED(collection->GetCount(&count))) {
    return {};
  }

  std::vector<flutter::EncodableValue> devices;
  for (UINT index = 0; index < count; ++index) {
    Microsoft::WRL::ComPtr<IMMDevice> device;
    if (FAILED(collection->Item(index, device.ReleaseAndGetAddressOf())) ||
        !device) {
      continue;
    }

    std::string identifier = GetDeviceId(device.Get());
    std::string name = GetFriendlyName(device.Get());
    if (name.empty()) {
      name = identifier.empty() ? "Unknown microphone" : identifier;
    }

    devices.push_back(flutter::EncodableValue(
        BuildDeviceMap(name, identifier)));
  }

  return devices;
}

}  // namespace

void RegisterWindowsAudioGateChannel(flutter::FlutterEngine* engine) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          engine->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler([](const auto& call, auto result) {
    if (call.method_name() == "listCaptureDevices") {
      result->Success(flutter::EncodableValue(ListCaptureDevices()));
      return;
    }

    result->NotImplemented();
  });

  static std::vector<
      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>>
      channels;
  channels.push_back(std::move(channel));
}
