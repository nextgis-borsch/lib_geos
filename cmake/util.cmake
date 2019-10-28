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

    set(VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/Version.txt)
    file(READ ${VERSION_FILE} VERSION1_H_CONTENTS)

    string(REGEX MATCH "GEOS_VERSION_MAJOR=([0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_major ${CMAKE_MATCH_1})
    string(REGEX MATCH "GEOS_VERSION_MINOR=([0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_minor ${CMAKE_MATCH_1})
    string(REGEX MATCH "GEOS_VERSION_PATCH=([0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_patch ${CMAKE_MATCH_1})
    # OPTIONS: "", "dev", "rc1" etc.
    string(REGEX MATCH "GEOS_PATCH_WORD=([a-zA-Z0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_patch_word ${CMAKE_MATCH_1})

    # Version of JTS this release is bound to
    string(REGEX MATCH "JTS_PORT=([0-9a-zA-Z\\.]+)" _ ${VERSION1_H_CONTENTS})
    set(JTS_PORT ${CMAKE_MATCH_1})

    # Version of public C API
    string(REGEX MATCH "CAPI_INTERFACE_CURRENT=([0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_capi_current ${CMAKE_MATCH_1})
    string(REGEX MATCH "CAPI_INTERFACE_REVISION=([0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_capi_revision ${CMAKE_MATCH_1})
    string(REGEX MATCH "CAPI_INTERFACE_AGE=([0-9]+)" _ ${VERSION1_H_CONTENTS})
    set(_version_capi_age ${CMAKE_MATCH_1})

    unset(VERSION1_H_CONTENTS)

    # GEOS release version
    set(VERSION_MAJOR ${_version_major})
    set(VERSION_MINOR ${_version_minor})
    set(VERSION_PATCH ${_version_patch})

     # GEOS C API version
    set(CAPI_INTERFACE_CURRENT ${_version_capi_current})
    set(CAPI_INTERFACE_REVISION ${_version_capi_revision})
    set(CAPI_INTERFACE_AGE ${_version_capi_age})

    math(EXPR _version_capi_major "${_version_capi_current} - ${_version_capi_age}")
    set(CAPI_VERSION_MAJOR ${_version_capi_major})
    set(CAPI_VERSION_MINOR ${_version_capi_age})
    set(CAPI_VERSION_PATCH ${_version_capi_revision})
    set(CAPI_VERSION "${_version_capi_major}.${_version_capi_age}.${_version_capi_revision}")


    set(${major} ${VERSION_MAJOR} PARENT_SCOPE)
    set(${minor} ${VERSION_MINOR} PARENT_SCOPE)
    set(${patch} ${VERSION_PATCH} PARENT_SCOPE)
    set(${api_carrent} ${CAPI_VERSION_MAJOR} PARENT_SCOPE)
    set(${api_rev} ${CAPI_VERSION_MINOR} PARENT_SCOPE)
    set(${api_age} ${CAPI_VERSION_PATCH} PARENT_SCOPE)
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
    
    if(NOT DEFINED BUILD_STATIC_LIBS)
      set(BUILD_STATIC_LIBS OFF)
    endif()

    get_prefix(STATIC_PREFIX ${BUILD_STATIC_LIBS})

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
