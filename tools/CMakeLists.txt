#################################################################################
#
# GEOS tools (geos-config) build configuration for CMake build system
#
# Copyright (C) 2009 Mateusz Loskot <mateusz@loskot.net>
#
# This is free software; you can redistribute and/or modify it under
# the terms of the GNU Lesser General Public Licence as published
# by the Free Software Foundation.
# See the COPYING file for more information.
#
#################################################################################

if(UNIX)

  if(APPLE AND GEOS_ENABLE_MACOSX_FRAMEWORK AND GEOS_ENABLE_MACOSX_FRAMEWORK_UNIXCOMPAT)
    set(installdest ${PROJECT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/unix/bin)
    set(prefix ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/unix)
  elseif(APPLE AND GEOS_ENABLE_MACOSX_FRAMEWORK)
    # just a dummy so installdest not set
    # want geos-config only for Mac unix build or framework+unixcompat
  else()
    set(installdest ${INSTALL_BIN_DIR})
    set(prefix ${CMAKE_INSTALL_PREFIX})
  endif()

  set(exec_prefix ${prefix}/${INSTALL_BIN_DIR})
  set(libdir ${prefix}/${INSTALL_LIB_DIR})

  if(installdest)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/geos-config.cmake ${CMAKE_CURRENT_BINARY_DIR}/geos-config)    
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/geos-config
      DESTINATION ${installdest}
      PERMISSIONS
      OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/geos.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/geos.pc)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/geos.pc
      DESTINATION INSTALL_LIB_DIR/pkgconfig)
  endif()

endif()
