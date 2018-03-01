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

install(FILES geos.h DESTINATION ${installdest})

install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/geos/platform.h
            ${CMAKE_CURRENT_BINARY_DIR}/geos/version.h
        DESTINATION ${installdest}/geos)

install(DIRECTORY geos/
    DESTINATION ${installdest}/geos
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.inl"
    PATTERN ".svn" EXCLUDE)

# Some post-processing for the framework
# luckily GEOS uses header subdir already, just need to change case
#if(APPLE AND GEOS_ENABLE_MACOSX_FRAMEWORK)
#  install(CODE
#    "execute_process(COMMAND find \"${installdest}\" -name *.* -print0
#    COMMAND xargs -0 sed -E -i \"\" \"s,# *include[[:space:]]+<geos/,#include <GEOS/,g\")")
#  install(CODE
#    "execute_process(COMMAND ln -sfh Versions/Current/Headers \"${INSTALL_LIB_DIR}/${FRAMEWORK_NAME}.framework/Headers\")")
#endif()

#################################################################################
# Group source files for IDE source explorers (e.g. Visual Studio)
#################################################################################
GenerateSourceGroups(include)
