#################################################################################
#
# GEOS C++ library build configuration for CMake build system
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

file(GLOB_RECURSE geos_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
file(GLOB_RECURSE geos_ALL_HEADERS ${CMAKE_SOURCE_DIR}/include/*.h) # fix source_group issue

if(OSX_FRAMEWORK)
  # OS X frameworks don't have static libs
  # also 1 binary, so include CAPI here
  # and, make name all caps

  set(geos_c_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/../capi/geos_c.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../capi/geos_ts_c.cpp)

    set(geos_HHEADERS
        ${CMAKE_SOURCE_DIR}/include/geos.h
    )

  add_library(${FRAMEWORK_NAME} SHARED ${geos_SOURCES} ${geos_c_SOURCES} ${geos_HHEADERS})

  math(EXPR CVERSION "${VERSION_MAJOR} + 1")
 	# VERSION = current version, SOVERSION = compatibility version
  set_target_properties(${FRAMEWORK_NAME}
    PROPERTIES
    CLEAN_DIRECT_OUTPUT 1
    FRAMEWORK 1
    VERSION "${CVERSION}.${VERSION_MINOR}.${VERSION_PATCH}"
 	  SOVERSION ${CVERSION}
    FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
#    BUILD_WITH_INSTALL_RPATH TRUE
#    INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}"
#    MACOSX_FRAMEWORK_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in"
    MACOSX_FRAMEWORK_BUNDLE_VERSION "GEOS ${VERSION}"
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
    MACOSX_FRAMEWORK_IDENTIFIER org.osgeo.geos
    XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
    PUBLIC_HEADER "${geos_HHEADERS}"
    )

  set(EXPORT_TARGETS ${FRAMEWORK_NAME} ${LIB_NAME} PARENT_SCOPE)

  install(TARGETS ${FRAMEWORK_NAME} FRAMEWORK DESTINATION ${INSTALL_LIB_DIR})

  if(GEOS_ENABLE_MACOSX_FRAMEWORK_UNIXCOMPAT)
    # Unix compatibility option, provides typical bin/lib/include folder
    # structure for framework-challenged projects

    set(GEOS_FWDIR "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/${FRAMEWORK_NAME}.framework")
    set(GEOS_FWDIR_VER "${GEOS_FWDIR}/Versions/${VERSION_MAJOR}")
    install(CODE "execute_process(COMMAND mkdir -p \"${GEOS_FWDIR_VER}/unix/bin\")")
    install(CODE "execute_process(COMMAND mkdir -p \"${GEOS_FWDIR_VER}/unix/include\")")
    install(CODE "execute_process(COMMAND mkdir -p \"${GEOS_FWDIR_VER}/unix/lib\")")
    install(CODE "execute_process(COMMAND ln -sfh ../../Headers \"${GEOS_FWDIR_VER}/unix/include/geos\")")
    install(CODE "execute_process(COMMAND ln -sf ../../Headers/geos_c.h \"${GEOS_FWDIR_VER}/unix/include/geos_c.h\")")
    install(CODE "execute_process(COMMAND ln -sf ../../${FRAMEWORK_NAME} \"${GEOS_FWDIR_VER}/unix/lib/libgeos.dylib\")")
    install(CODE "execute_process(COMMAND ln -sf ../../${FRAMEWORK_NAME} \"${GEOS_FWDIR_VER}/unix/lib/libgeos_c.dylib\")")
    install(CODE "execute_process(COMMAND ln -sfh Versions/Current/unix \"${GEOS_FWDIR}/unix\")")
  endif()

else()

    if(BUILD_SHARED_LIBS)
        set(LIB_TYPE SHARED)
        set(LIB_NAME ${PROJECT_NAME})
    else()
        set(LIB_TYPE STATIC)
        set(LIB_NAME ${PROJECT_NAME}static)
    endif()

  add_library(${LIB_NAME} ${LIB_TYPE} ${geos_SOURCES} ${geos_ALL_HEADERS})

    if(BUILD_SHARED_LIBS)
      set_target_properties(${LIB_NAME}
        PROPERTIES
        DEFINE_SYMBOL GEOS_DLL_EXPORT
        VERSION ${VERSION}
        SOVERSION ${SOVERSION}
        CLEAN_DIRECT_OUTPUT 1)

        if(BUILD_STATIC_LIBS)
            add_library(${LIB_NAME}static STATIC ${geos_SOURCES} ${geos_ALL_HEADERS})
            set(INSTALL_TARGETS ${INSTALL_TARGETS} ${LIB_NAME}static)
            if(WIN32)
                set_target_properties(${LIB_NAME}static PROPERTIES OUTPUT_NAME ${LIB_NAME}_i)
            else()
                set_target_properties(${LIB_NAME}static PROPERTIES OUTPUT_NAME ${LIB_NAME})
            endif()
        endif()

    else()
      set_target_properties(${LIB_NAME}
        PROPERTIES
        OUTPUT_NAME "geos"
        PREFIX "lib"
        CLEAN_DIRECT_OUTPUT 1)
    endif()

    set(INSTALL_TARGETS ${INSTALL_TARGETS} ${LIB_NAME})
    set(EXPORT_TARGETS ${EXPORT_TARGETS} ${LIB_NAME} PARENT_SCOPE)

    if(NOT WIN32 AND BUILD_SHARED_LIBS)
        CREATE_SYMLINK($<TARGET_FILE:${LIB_NAME}> libgeos-${VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX} ${LIB_NAME})
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libgeos-${VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX}
            DESTINATION ${INSTALL_LIB_DIR})
    endif()
endif()

#################################################################################
# Installation
#################################################################################

if(NOT OSX_FRAMEWORK)
  install(TARGETS ${INSTALL_TARGETS}
    RUNTIME DESTINATION ${INSTALL_BIN_DIR}
    LIBRARY DESTINATION ${INSTALL_LIB_DIR}
    ARCHIVE DESTINATION ${INSTALL_LIB_DIR})
endif()

#################################################################################
# Group source files for IDE source explorers (e.g. Visual Studio)
#################################################################################
GenerateSourceGroups(src)
