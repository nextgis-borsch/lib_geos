#################################################################################
#
# Main GEOS build configuration file for CMake build system
#
# Copyright (C) 2009 Mateusz Loskot <mateusz@loskot.net>
# Copyright (C) 2016, NextGIS <info@nextgis.com>
#
# This is free software; you can redistribute and/or modify it under
# the terms of the GNU Lesser General Public Licence as published
# by the Free Software Foundation.
# See the COPYING file for more information.
#
#################################################################################
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)

project(geos)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(FRAMEWORK_NAME ${PROJECT_NAME})
    set(APPLE TRUE)
    set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/Applications" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${FRAMEWORK_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_INC_ROOT_DIR ${INSTALL_INC_DIR})
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(CMAKE_MACOSX_RPATH ON)
    set(GEOS_ENABLE_MACOSX_FRAMEWORK TRUE)
    set(GEOS_ENABLE_MACOSX_FRAMEWORK_UNIXCOMPAT FALSE)
else()
    include(GNUInstallDirs)
    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_FULL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_FULL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR "${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PROJECT_NAME}" CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_INC_ROOT_DIR "${CMAKE_INSTALL_FULL_INCLUDEDIR}" CACHE INTERNAL "Installation directory for geos_c.h" FORCE)
endif()

#################################################################################
# Setup GEOS version
#################################################################################
include (util)

check_version(VERSION_MAJOR VERSION_MINOR VERSION_PATCH CAPI_INTERFACE_CURRENT CAPI_INTERFACE_REVISION CAPI_INTERFACE_AGE JTS_PORT)
# GEOS C++ library SONAME will use these encoding ABI break at every release
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
set(SOVERSION 1)

set(FRAMEWORK_VERSION "${VERSION_MAJOR}")

report_version(${PROJECT_NAME} ${VERSION})

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS "Setting GEOS version ${VERSION} as port of JTS ${JTS_PORT}")
endif()

math(EXPR CAPI_VERSION_MAJOR "${CAPI_INTERFACE_CURRENT} - ${CAPI_INTERFACE_AGE}")
set(CAPI_VERSION_MINOR ${CAPI_INTERFACE_AGE})
set(CAPI_VERSION_PATCH ${CAPI_INTERFACE_REVISION})
set(CAPI_VERSION "${CAPI_VERSION_MAJOR}.${CAPI_VERSION_MINOR}.${CAPI_VERSION_PATCH}")

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS "Setting GEOS C API version ${CAPI_VERSION}")
endif()

if (NOT WIN32)
  set(CAPI_SOVERSION ${CAPI_VERSION_MAJOR})
  if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS "Setting GEOS C API soversion ${CAPI_SOVERSION}")
  endif()
endif()

#################################################################################
# Check custom global options
#################################################################################

option(GEOS_ENABLE_TESTS
  "Set to ON|OFF (default) to control build of GEOS tests package" OFF)

option(GEOS_ENABLE_INLINE
  "Set to OFF|ON (default) to control GEOS compilation with small functions inlining" ON)

if(NOT MSVC)
  option(GEOS_ENABLE_ASSERT
    "Set to ON|OFF (default) to build GEOS with assert() macro enabled" OFF)
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
  option(GEOS_ENABLE_FLOATSTORE
    "Set to OFF|ON (default) to control IEEE754 conformance and remove extra precision" ON)
endif()

if(APPLE)
  option(GEOS_ENABLE_MACOSX_FRAMEWORK
    "Set to ON|OFF (default) to build GEOS as a Mac OS X framework" OFF)
  option(GEOS_ENABLE_MACOSX_FRAMEWORK_UNIXCOMPAT
    "Set to ON|OFF (default) to add Unix compatibility to the Mac OS X framework" OFF)
endif()

#################################################################################
# Setup C/C++ compiler options
#################################################################################

if(NOT MSVC_IDE)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING
      "Choose the type of build, options are: None Debug Release" FORCE)
  endif()
  if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS "Setting GEOS build type - ${CMAKE_BUILD_TYPE}")
  endif()
endif()

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_definitions(-D_DEBUG)
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)

  # General options
  set(CMAKE_CXX_FLAGS "-pedantic -ansi ${CMAKE_CXX_FLAGS}")

  # Numerical stability
  if(GEOS_ENABLE_FLOATSTORE)
    # Remove extra precision by forcing conformance to IEEE 754 rather than IEEE 854
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffloat-store")
  endif()

  if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS "Forcing IEEE 754 using flag -ffloat-store - ${GEOS_ENABLE_FLOATSTORE}")
  endif()

  # Warnings specification
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wno-long-long")

  # Turn on Position Independent Code generation for GEOS C shared library
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

  # Enable glibc ISO C99 features (macros isfinite, isnan)
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_ISOC99_SOURCE=1")

elseif(MSVC)

  # Set pedantic mode by default
  #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
  string(REGEX REPLACE "/W[0-9]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

  if(NOT (MSVC_VERSION LESS 1400)) # Visual Studio 2005 or later

    # Option is to enable the /MP switch for Visual Studio 2005 or later
    option(GEOS_MSVC_ENABLE_MP
      "Set to ON to build GEOS with the /MP option (Visual Studio 2005 and above)." ON)
    mark_as_advanced(GEOS_MSVC_ENABLE_MP)
    if(GEOS_MSVC_ENABLE_MP)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
    endif()
    if(NOT SUPPRESS_VERBOSE_OUTPUT)
        message(STATUS "Setting Visual Studio 2005+ option /MP to ${GEOS_MSVC_ENABLE_MP}")
    endif()

    add_definitions(-D_SCL_SECURE_NO_WARNINGS)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-DNOMINMAX)
  endif()

endif()

if(GEOS_ENABLE_INLINE)
  add_definitions(-DGEOS_INLINE)
endif()

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS
        "Setting GEOS compilation with small functions inlining - ${GEOS_ENABLE_INLINE}")
endif()

if(NOT MSVC)
  if(GEOS_ENABLE_ASSERT)
    string(REGEX REPLACE "[-/]D.*NDEBUG" "-U NDEBUG"
      CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
  endif()
  if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS
      "Setting GEOS compilation with assert() macro enabled - ${GEOS_ENABLE_ASSERT}")
  endif()
endif()

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

#################################################################################
# Setup C/C++ library features
#################################################################################

# check header files
include(CheckIncludeFiles)

check_include_files(stdint.h HAVE_STDINT_H)
check_include_files(inttypes.h HAVE_INTTYPES_H)
check_include_files(ieeefp.h HAVE_IEEEFP_H)

# check types and sizes
include(CheckTypeSize)

if(MSVC)
  check_type_size("__int64" HAVE_INT64_T_64)
else()
  if(HAVE_STDINT_H OR HAVE_INTTYPES_H)
    check_type_size("int64_t" HAVE_INT64_T_64)
  else()
    check_type_size("long long int" HAVE_LONG_LONG_INT_64)
  endif()
endif()

# check functions and macros
include(CheckPrototypeExists)
include(CheckSymbolExists)

check_prototype_exists(isnan cmath HAVE_STD_ISNAN)
if(NOT HAVE_STD_ISNAN)
  if(MSVC)
    check_prototype_exists(_isnan float.h HAVE_ISNAN)
  elseif(APPLE)
    check_prototype_exists(__isnand math.h HAVE_ISNAND_XCODE)
    if(NOT HAVE_ISNAND_XCODE)
      check_prototype_exists(__inline_isnand math.h HAVE_INLINE_ISNAND_XCODE)
    endif()
  else()
    check_symbol_exists(isnan math.h HAVE_ISNAN)
  endif()
endif()

check_prototype_exists(isfinite cmath HAVE_STD_ISFINITE)

if(NOT HAVE_STD_ISFINITE)
  if(MSVC)
    check_prototype_exists(_finite float.h HAVE_FINITE)
  else()
    #CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
    check_symbol_exists(isfinite math.h HAVE_ISFINITE)
  endif()
endif()


################################################################################
# Setup include directories
#################################################################################

# for including GEOS C++ API headers
include_directories(${geos_SOURCE_DIR}/include)

# for including build-specific GEOS C API headers
include_directories(${geos_BINARY_DIR}/capi)

# for including build-specific version.h, platform.h and geos_c.h
include_directories(${geos_BINARY_DIR}/include)

#################################################################################
# Setup checks and generate config headers
#################################################################################

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h)
  message(STATUS "Disabling existing ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h")

  if(${CMAKE_MAJOR_VERSION} EQUAL 2 AND ${CMAKE_MINOR_VERSION} EQUAL 6)
    file(REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h)
    set(PH_RESULT "removed")
  else()
    file(RENAME
      ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h
      ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h.disabled)
      set(PH_RESULT "renamed")
  endif()

  message(STATUS "Disabling existing ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h - ${PH_RESULT}")
endif()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/geos/platform.h.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/include/geos/platform.h)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/include/geos/version.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/include/geos/version.h @ONLY)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/capi/geos_c.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/capi/geos_c.h @ONLY)

#################################################################################
# Configure tests
#################################################################################

if(GEOS_ENABLE_TESTS)
 enable_testing()
  # Define "make check" as alias for "make test"
  add_custom_target(check COMMAND ctest)
endif()

#################################################################################
# Configure subdirectories
#################################################################################
include(GenerateSourceGroups)

set(EXPORT_TARGETS)

add_subdirectory(include)
add_subdirectory(src)
add_subdirectory(capi)
add_subdirectory(tests)
add_subdirectory(tools)
#TODO: add_subdirectory(doc)

set(EXPORT_NAME ${PROJECT_NAME})

if (REGISTER_PACKAGE)
    export(TARGETS ${EXPORT_TARGETS} FILE ${EXPORT_NAME}-exports.cmake)
    set(EXPORT_PACKAGE_NAME ${EXPORT_NAME})
    string(TOUPPER ${EXPORT_PACKAGE_NAME} EXPORT_PACKAGE_NAME_UPPER)
    set(EXPORT_PACKAGE_LIB_NAMES ${EXPORT_TARGETS})

    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
        INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR} ) 
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${EXPORT_TARGETS} FILE ${EXPORT_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

#################################################################################
# Install/Uninstall
#################################################################################

add_custom_target(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake")

#################################################################################
# DEBUG settings - TODO: make a summary

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS "CMake ${CMAKE_VERSION} successfully configured ${PROJECT_NAME} using ${CMAKE_GENERATOR} generator")
endif()
