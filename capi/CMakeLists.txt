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

if(NOT GEOS_ENABLE_MACOSX_FRAMEWORK) 
  # if building OS X framework, CAPI built into C++ library 
  
    if(BUILD_SHARED_LIBS)
        set(LIB_TYPE SHARED)
        set(LIB_NAME ${PROJECT_NAME}_c)
    else()
        message(WARNING "Some functions are not available due to export static functions problem")
        set(LIB_TYPE STATIC)
        set(LIB_NAME ${PROJECT_NAME}_cstatic)
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

if(APPLE AND GEOS_ENABLE_MACOSX_FRAMEWORK)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/geos_c.h
    DESTINATION GEOS.framework/Versions/${VERSION_MAJOR}/Headers)
  install(CODE "execute_process(COMMAND sed -E -i \"\" \"s,# *include[[:space:]]+<geos/,#include <GEOS/,g\" \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/GEOS.framework/Versions/${VERSION_MAJOR}/Headers/geos_c.h\")")
else()
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/geos_c.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
endif()

if(NOT GEOS_ENABLE_MACOSX_FRAMEWORK) 
  install(TARGETS ${LIB_NAME}
    RUNTIME DESTINATION ${INSTALL_BIN_DIR}
    LIBRARY DESTINATION ${INSTALL_LIB_DIR}
    ARCHIVE DESTINATION ${INSTALL_LIB_DIR})
endif()

#################################################################################
# Group source files for IDE source explorers (e.g. Visual Studio)
#################################################################################

source_group("Header Files" FILES ${geos_capi_HEADERS})
