#################################################################################
#
# GEOS C library build configuration for CMake build system
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

if(WIN32)
    add_definitions("-DGEOS_DLL_EXPORT=1")
endif()

set(geos_c_SOURCES
  geos_c.cpp
  geos_ts_c.cpp)

file(GLOB geos_capi_HEADERS ${CMAKE_BINARY_DIR}/capi/*.h) # fix source_group issue

if(NOT OSX_FRAMEWORK)
  # if building OS X framework, CAPI built into C++ library
    set(LIB_NAME ${PROJECT_NAME}_c)
    if(BUILD_SHARED_LIBS)
        set(LIB_TYPE SHARED)
    else()
        message(WARNING "Some functions are not available due to export static functions problem")
        set(LIB_TYPE STATIC)
    endif()

  add_library(${LIB_NAME} ${LIB_TYPE} ${geos_c_SOURCES})

  target_link_libraries(${LIB_NAME} ${EXPORT_TARGETS})

  if (WIN32)
    set_target_properties(${LIB_NAME}
      PROPERTIES
      VERSION ${CAPI_VERSION}
      CLEAN_DIRECT_OUTPUT 1)
  else()
    set_target_properties(${LIB_NAME}
      PROPERTIES
      OUTPUT_NAME "geos_c"
      PREFIX "lib"
      VERSION ${CAPI_VERSION}
      SOVERSION ${CAPI_SOVERSION}
      CLEAN_DIRECT_OUTPUT 1)
  endif()

  set(EXPORT_TARGETS ${EXPORT_TARGETS} ${LIB_NAME} PARENT_SCOPE)

endif()

#################################################################################
# Installation
#################################################################################

if(OSX_FRAMEWORK)
    install(FILES ${geos_capi_HEADERS}
        DESTINATION "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Headers/")
    #  install(CODE "execute_process(COMMAND sed -E -i \"\" \"s,# *include[[:space:]]+<geos/,#include <GEOS/,g\" \"${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Headers/geos_c.h\")")
else()
    install(FILES ${geos_capi_HEADERS}
        DESTINATION ${INSTALL_INC_DIR})

    target_include_directories(${LIB_NAME} PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    )

    if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
        install(TARGETS ${LIB_NAME}
            EXPORT ${PACKAGE_UPPER_NAME}Targets
            RUNTIME DESTINATION ${INSTALL_BIN_DIR}
            LIBRARY DESTINATION ${INSTALL_LIB_DIR}
            ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
            INCLUDES DESTINATION ${INSTALL_INC_DIR}
            FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
        )
    endif()
endif()

#################################################################################
# Group source files for IDE source explorers (e.g. Visual Studio)
#################################################################################

source_group("Header Files" FILES ${geos_capi_HEADERS})
