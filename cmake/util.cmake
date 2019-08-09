################################################################################
# Project:  external projects
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015,2019, NextGIS <info@nextgis.com>
# Copyright (C) 2015,2019 Dmitry Baryshnikov
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script.  If not, see <http://www.gnu.org/licenses/>.
################################################################################
function(check_version major minor patch api_carrent api_rev api_age jts_port)

    set(VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/include/geos/version.h.vc)

    file(READ ${VERSION_FILE} VERSION1_H_CONTENTS)

    string(REGEX MATCH "GEOS_VERSION_MAJOR[ \t]+([0-9]+)"
        GEOS_VERSION_MAJOR ${VERSION1_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
        GEOS_VERSION_MAJOR ${GEOS_VERSION_MAJOR})
    string(REGEX MATCH "GEOS_VERSION_MINOR[ \t]+([0-9]+)"
        GEOS_VERSION_MINOR ${VERSION1_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
        GEOS_VERSION_MINOR ${GEOS_VERSION_MINOR})
    string(REGEX MATCH "GEOS_VERSION_PATCH[ \t]+([0-9]+)"
        GEOS_VERSION_PATCH ${VERSION1_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
        GEOS_VERSION_PATCH ${GEOS_VERSION_PATCH})
    string(REGEX MATCH "GEOS_JTS_PORT[ \t]+([0-9.\"]+)"
        GEOS_JTS_PORT ${VERSION1_H_CONTENTS})
    string (REGEX MATCH "([0-9.]+)"
        GEOS_JTS_PORT ${GEOS_JTS_PORT})

    # GEOS release version
    set(VERSION_MAJOR ${GEOS_VERSION_MAJOR})
    set(VERSION_MINOR ${GEOS_VERSION_MINOR})
    set(VERSION_PATCH ${GEOS_VERSION_PATCH})
    # JTS_PORT is the version of JTS this release is bound to
    set(JTS_PORT ${GEOS_JTS_PORT})

    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/capi/geos_c.h.in VERSION2_H_CONTENTS)

    string(REGEX MATCH "GEOS_CAPI_VERSION_MAJOR[ \t]+([0-9]+)"
        GEOS_CAPI_VERSION_MAJOR ${VERSION2_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
        GEOS_CAPI_VERSION_MAJOR ${GEOS_CAPI_VERSION_MAJOR})
    string(REGEX MATCH "GEOS_CAPI_VERSION_MINOR[ \t]+([0-9]+)"
        GEOS_CAPI_VERSION_MINOR ${VERSION2_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
        GEOS_CAPI_VERSION_MINOR ${GEOS_CAPI_VERSION_MINOR})
    string(REGEX MATCH "GEOS_CAPI_VERSION_PATCH[ \t]+([0-9]+)"
        GEOS_CAPI_VERSION_PATCH ${VERSION2_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
        GEOS_CAPI_VERSION_PATCH ${GEOS_CAPI_VERSION_PATCH})

    # GEOS C API version
    set(CAPI_INTERFACE_CURRENT ${GEOS_CAPI_VERSION_MAJOR})
    set(CAPI_INTERFACE_REVISION ${GEOS_CAPI_VERSION_MINOR})
    set(CAPI_INTERFACE_AGE ${GEOS_CAPI_VERSION_PATCH})

    set(${major} ${VERSION_MAJOR} PARENT_SCOPE)
    set(${minor} ${VERSION_MINOR} PARENT_SCOPE)
    set(${patch} ${VERSION_PATCH} PARENT_SCOPE)
    set(${api_carrent} ${CAPI_INTERFACE_CURRENT} PARENT_SCOPE)
    set(${api_rev} ${CAPI_INTERFACE_REVISION} PARENT_SCOPE)
    set(${api_age} ${CAPI_INTERFACE_AGE} PARENT_SCOPE)
    set(${jts_port} ${JTS_PORT} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${VERSION_FILE} VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
    get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION}\n${VERSION_DATETIME}\n${PROJECT_CPACK_FILENAME}")

endfunction(check_version)

function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")

    message("${BoldYellow}${name} version ${ver}${ColourReset}")

endfunction()

# macro to find programs on the host OS
macro( find_exthost_program )
    if(CMAKE_CROSSCOMPILING)
        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )

        find_program( ${ARGN} )

        set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
        set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
    else()
        find_program( ${ARGN} )
    endif()
endmacro()

function(get_prefix prefix IS_STATIC)
  if(IS_STATIC)
    set(STATIC_PREFIX "static-")
      if(ANDROID)
        set(STATIC_PREFIX "${STATIC_PREFIX}android-${ANDROID_ABI}-")
      elseif(IOS)
        set(STATIC_PREFIX "${STATIC_PREFIX}ios-${IOS_ARCH}-")
      endif()
    endif()
  set(${prefix} ${STATIC_PREFIX} PARENT_SCOPE)
endfunction()


function(get_cpack_filename ver name)
    get_compiler_version(COMPILER)
    get_prefix(STATIC_PREFIX BUILD_STATIC_LIBS)

    set(${name} ${PROJECT_NAME}-${ver}-${STATIC_PREFIX}${COMPILER} PARENT_SCOPE)
endfunction()

function(get_compiler_version ver)
    ## Limit compiler version to 2 or 1 digits
    string(REPLACE "." ";" VERSION_LIST ${CMAKE_C_COMPILER_VERSION})
    list(LENGTH VERSION_LIST VERSION_LIST_LEN)
    if(VERSION_LIST_LEN GREATER 2 OR VERSION_LIST_LEN EQUAL 2)
        list(GET VERSION_LIST 0 COMPILER_VERSION_MAJOR)
        list(GET VERSION_LIST 1 COMPILER_VERSION_MINOR)
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${COMPILER_VERSION_MAJOR}.${COMPILER_VERSION_MINOR})
    else()
        set(COMPILER ${CMAKE_C_COMPILER_ID}-${CMAKE_C_COMPILER_VERSION})
    endif()

    if(WIN32)
        if(CMAKE_CL_64)
            set(COMPILER "${COMPILER}-64bit")
        endif()
    endif()

    set(${ver} ${COMPILER} PARENT_SCOPE)
endfunction()
