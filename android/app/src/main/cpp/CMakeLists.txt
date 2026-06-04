cmake_minimum_required(VERSION 3.18.1)

project(food_segmenter CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ncnn 预编译静态库位于 ${PROJECT_SOURCE_DIR}/ncnn/ncnn-20260526-android-vulkan/<abi>/...
# 本轮只打包 arm64-v8a（与真机一致），不做全 ABI 兼容。
# 该目录内 lib/cmake 提供了 ncnnConfig.cmake + ncnnConfigVersion.cmake，可直接 find_package。
set(NCNN_PREBUILT_DIR "${PROJECT_SOURCE_DIR}/ncnn/ncnn-20260526-android-vulkan/arm64-v8a")

if(NOT EXISTS "${NCNN_PREBUILT_DIR}/include/ncnn")
    message(FATAL_ERROR "ncnn prebuilt include not found at ${NCNN_PREBUILT_DIR}/include/ncnn")
endif()

if(NOT EXISTS "${NCNN_PREBUILT_DIR}/lib/cmake/ncnn/ncnnConfig.cmake")
    message(FATAL_ERROR "ncnnConfig.cmake not found at ${NCNN_PREBUILT_DIR}/lib/cmake/ncnn")
endif()

# Android NDK 工具链对 CMAKE_PREFIX_PATH 行为不一致，强制用 NCNN_DIR + ROOT 形式。
set(ncnn_DIR "${NCNN_PREBUILT_DIR}/lib/cmake/ncnn")
set(CMAKE_FIND_ROOT_PATH "${NCNN_PREBUILT_DIR}")
list(APPEND CMAKE_PREFIX_PATH "${NCNN_PREBUILT_DIR}/lib/cmake")

find_package(ncnn REQUIRED CONFIG REQUIRED)

add_library(food_segmenter SHARED food_segmenter.cpp)

# link ncnn 主库 + 公共 Vulkan 静态库（Vulkan 后端被包含在同一份 libncnn.a）
target_link_libraries(food_segmenter
    ncnn
    log
    android
    z
)

# 让 include 目录直接生效，方便后续接 NDK 之外的头文件
target_include_directories(food_segmenter PRIVATE
    ${NCNN_PREBUILT_DIR}/include
)
