# Project-level configuration.
cmake_minimum_required(VERSION 3.14)

function(_ne_select_latest_file out_var version_regex)
  set(_ne_best_file "")
  set(_ne_best_version "")
  foreach(_ne_candidate IN LISTS ARGN)
    string(REGEX MATCH "${version_regex}" _ne_version_match "${_ne_candidate}")
    if(CMAKE_MATCH_1)
      set(_ne_candidate_version "${CMAKE_MATCH_1}")
      if(_ne_best_file STREQUAL "" OR _ne_candidate_version VERSION_GREATER _ne_best_version)
        set(_ne_best_file "${_ne_candidate}")
        set(_ne_best_version "${_ne_candidate_version}")
      endif()
    endif()
  endforeach()
  set(${out_var} "${_ne_best_file}" PARENT_SCOPE)
endfunction()

# Newer CMake/MSVC combinations can fail during Windows resource compilation
# if the manifest tool or compiler is not on PATH. Resolve both dynamically
# before project() runs so configure stays stable across toolset updates.
if(NOT CMAKE_MT OR CMAKE_MT STREQUAL "CMAKE_MT-NOTFOUND")
  set(_ne_windows_kits_roots)
  set(_ne_windows_sdk_dir "$ENV{WindowsSdkDir}")
  if(NOT _ne_windows_sdk_dir STREQUAL "")
    list(APPEND _ne_windows_kits_roots "${_ne_windows_sdk_dir}")
  endif()
  if(EXISTS "C:/Program Files (x86)")
    list(APPEND _ne_windows_kits_roots "C:/Program Files (x86)/Windows Kits/10")
  endif()
  set(_ne_program_files "$ENV{ProgramFiles}")
  if(NOT _ne_program_files STREQUAL "")
    list(APPEND _ne_windows_kits_roots "${_ne_program_files}/Windows Kits/10")
  endif()

  set(_ne_mt_candidates)
  foreach(_ne_windows_kits_root IN LISTS _ne_windows_kits_roots)
    if(EXISTS "${_ne_windows_kits_root}")
      file(GLOB _ne_mt_candidates_for_root
        "${_ne_windows_kits_root}/bin/*/x64/mt.exe"
        "${_ne_windows_kits_root}/bin/*/x86/mt.exe"
        "${_ne_windows_kits_root}/bin/*/arm64/mt.exe"
      )
      list(APPEND _ne_mt_candidates ${_ne_mt_candidates_for_root})
    endif()
  endforeach()
  _ne_select_latest_file(_NE_MT_EXE "Windows Kits/10/bin/([^/]+)/" ${_ne_mt_candidates})
  if(_NE_MT_EXE)
    set(CMAKE_MT "${_NE_MT_EXE}" CACHE FILEPATH "Windows manifest tool" FORCE)
  endif()
endif()

if(NOT CMAKE_C_COMPILER OR CMAKE_C_COMPILER STREQUAL "CMAKE_C_COMPILER-NOTFOUND")
  set(_ne_vswhere_candidates)
  if(EXISTS "C:/Program Files (x86)")
    list(APPEND _ne_vswhere_candidates "C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe")
  endif()
  set(_ne_program_files "$ENV{ProgramFiles}")
  if(NOT _ne_program_files STREQUAL "")
    list(APPEND _ne_vswhere_candidates "${_ne_program_files}/Microsoft Visual Studio/Installer/vswhere.exe")
  endif()

  set(_ne_vswhere_exe "")
  foreach(_ne_vswhere_candidate IN LISTS _ne_vswhere_candidates)
    if(EXISTS "${_ne_vswhere_candidate}")
      set(_ne_vswhere_exe "${_ne_vswhere_candidate}")
      break()
    endif()
  endforeach()

  if(_ne_vswhere_exe)
    execute_process(
      COMMAND "${_ne_vswhere_exe}"
        -latest
        -products *
        -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64
        -property installationPath
        -format value
      OUTPUT_VARIABLE _ne_vs_installation_path
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if(_ne_vs_installation_path)
      file(GLOB _ne_cl_candidates
        "${_ne_vs_installation_path}/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe"
        "${_ne_vs_installation_path}/VC/Tools/MSVC/*/bin/Hostx86/x64/cl.exe"
        "${_ne_vs_installation_path}/VC/Tools/MSVC/*/bin/Hostx64/x86/cl.exe"
      )
      _ne_select_latest_file(_NE_CL_EXE "VC/Tools/MSVC/([^/]+)/bin/" ${_ne_cl_candidates})
      if(_NE_CL_EXE)
        set(CMAKE_C_COMPILER "${_NE_CL_EXE}" CACHE FILEPATH "C compiler" FORCE)
      endif()
    endif()
  endif()
endif()

if(NOT CMAKE_CXX_COMPILER OR CMAKE_CXX_COMPILER STREQUAL "CMAKE_CXX_COMPILER-NOTFOUND")
  if(DEFINED _NE_CL_EXE AND _NE_CL_EXE)
    set(CMAKE_CXX_COMPILER "${_NE_CL_EXE}" CACHE FILEPATH "C++ compiler" FORCE)
  endif()
endif()

project(new_earth_command_dashboard LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "new_earth_command_dashboard")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
# Make the "install" step default, as it's required to run.
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
endif()

# Copy the native assets provided by the build.dart from all packages.
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
   DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
   COMPONENT Runtime)

# Fully re-copy the assets directory on each build to avoid having stale files
# from a previous install.
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
  DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Install the AOT library on non-Debug builds only.
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
  CONFIGURATIONS Profile;Release
  COMPONENT Runtime)
