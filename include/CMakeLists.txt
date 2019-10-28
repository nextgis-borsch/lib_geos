#################################################################################
#
# GEOS C++ library build configuration for CMake build system
#
# Copyright (C) 2009 Mateusz Loskot <mateusz@loskot.net>
#
# This is free software; you can redistribute and/or modify it under
# the terms of the GNU Lesser General Public Licence as published
# by the Free Software Foundation.
# See the COPYING file for more information.
#
#################################################################################

#################################################################################
# Install/Uninstall
#################################################################################

# There is a builtin cmake way to get headers in the right location
# for OS X framework, but it's not practical this complex tree

if(OSX_FRAMEWORK)
  set(installdest ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Versions/${FRAMEWORK_VERSION}/Headers)
else()
  set(installdest ${INSTALL_INC_DIR})
endif()

set(VERSION ${GEOS_VERSION})
set(VERSION_MAJOR ${GEOS_VERSION_MAJOR})
set(VERSION_MINOR ${GEOS_VERSION_MINOR})
set(VERSION_PATCH ${GEOS_VERSION_PATCH})

configure_file(${CMAKE_CURRENT_LIST_DIR}/geos/version.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/geos/version.h
  @ONLY)

unset(VERSION)
unset(VERSION_MAJOR)
unset(VERSION_MINOR)
unset(VERSION_PATCH)


set(ROOT_HEADERS
    ${CMAKE_CURRENT_BINARY_DIR}/geos/platform.h
    ${CMAKE_CURRENT_BINARY_DIR}/geos/version.h
)

install(FILES geos.h DESTINATION ${installdest})
install(FILES ${ROOT_HEADERS} DESTINATION ${installdest}/geos)

install(DIRECTORY geos/
    DESTINATION ${installdest}/geos
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.inl"
    PATTERN ".svn" EXCLUDE)
