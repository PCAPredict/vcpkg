set(VCPKG_PLATFORM_TOOLSET v140)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(TARGET_TRIPLET x64-windows)
set(VCPKG_DEFAULT_TRIPLET x64-windows)
set(CURRENT_PACKAGES_DIR ${VCPKG_ROOT_DIR}/packages/${PORT}_${TARGET_TRIPLET})
set(VCPKG_USE_HEAD_VERSION true)
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PCAPredict/cpprestsdk
    HEAD_REF master
)
if(NOT VCPKG_USE_HEAD_VERSION)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002_no_websocketpp_in_uwp.patch
    )
endif()
set(OPTIONS)
if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    SET(WEBSOCKETPP_PATH "${CURRENT_INSTALLED_DIR}/share/websocketpp")
    list(APPEND OPTIONS
        -DWEBSOCKETPP_CONFIG=${WEBSOCKETPP_PATH}
        -DWEBSOCKETPP_CONFIG_VERSION=${WEBSOCKETPP_PATH})
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Release
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DCPPREST_EXCLUDE_WEBSOCKETS=OFF
        -DCPPREST_EXPORT_DIR=share/pcacpprestsdk
    OPTIONS_DEBUG
        -DCASA_INSTALL_HEADERS=OFF
        -DCPPREST_INSTALL_HEADERS=OFF
)
vcpkg_install_cmake()
if(VCPKG_USE_HEAD_VERSION)
    vcpkg_fixup_cmake_targets()
endif()
file(INSTALL
    ${SOURCE_PATH}/license.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcacpprestsdk RENAME copyright)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
