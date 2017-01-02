################################################################################
# Project:  external projects
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
# Copyright (C) 2015 Dmitry Baryshnikov
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

    # GEOS release version
    set(VERSION_MAJOR 3)
    set(VERSION_MINOR 6)
    set(VERSION_PATCH 1)
    # JTS_PORT is the version of JTS this release is bound to
    set(JTS_PORT 1.13.0)

    # GEOS C API version
    set(CAPI_INTERFACE_CURRENT 11)
    set(CAPI_INTERFACE_REVISION 1)
    set(CAPI_INTERFACE_AGE 10)

    set(${major} ${VERSION_MAJOR} PARENT_SCOPE)
    set(${minor} ${VERSION_MINOR} PARENT_SCOPE)
    set(${patch} ${VERSION_PATCH} PARENT_SCOPE)
    set(${api_carrent} ${CAPI_INTERFACE_CURRENT} PARENT_SCOPE)
    set(${api_rev} ${CAPI_INTERFACE_REVISION} PARENT_SCOPE)
    set(${api_age} ${CAPI_INTERFACE_AGE} PARENT_SCOPE)
    set(${jts_port} ${JTS_PORT} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/geos_svn_revision.h VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}\n${VERSION_DATETIME}")

endfunction(check_version)

function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")

    message(STATUS "${BoldYellow}${name} version ${ver}${ColourReset}")

endfunction()

macro(CREATE_SYMLINK SRC_FILE DEST_FILE)
  FILE(REMOVE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE})
  if(WIN32 AND NOT CYGWIN AND NOT MSYS)
    ADD_CUSTOM_COMMAND(
        OUTPUT ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE}   ${CMAKE_CURRENT_BINARY_DIR}/${DEST_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  "${SRC_FILE}" ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  "${SRC_FILE}" ${CMAKE_CURRENT_BINARY_DIR}/${DEST_FILE}
        DEPENDS ${PNG_LIB_TARGETS}
        )
    ADD_CUSTOM_TARGET(${DEST_FILE}_COPY ALL DEPENDS ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE})
  else(WIN32 AND NOT CYGWIN AND NOT MSYS)
#    get_filename_component(LINK_TARGET "${SRC_FILE}" NAME)
#    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
#    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${LINK_TARGET}" ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
#    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${LINK_TARGET}" ${DEST_FILE} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    ADD_CUSTOM_COMMAND(
        OUTPUT ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE}   ${CMAKE_CURRENT_BINARY_DIR}/${DEST_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  "${SRC_FILE}" ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  "${SRC_FILE}" ${CMAKE_CURRENT_BINARY_DIR}/${DEST_FILE}
        DEPENDS ${PNG_LIB_TARGETS}
        )
    ADD_CUSTOM_TARGET(${DEST_FILE}_COPY ALL DEPENDS ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${DEST_FILE})
  endif(WIN32 AND NOT CYGWIN AND NOT MSYS)
endmacro()
