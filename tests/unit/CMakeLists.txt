#################################################################################
#
# GEOS unit tests build configuration for CMake build system
#
# Copyright (C) 2009 Mateusz Loskot <mateusz@loskot.net>
#
# This is free software; you can redistribute and/or modify it under
# the terms of the GNU Lesser General Public Licence as published
# by the Free Software Foundation.
# See the COPYING file for more information.
#
#################################################################################

set(STATUS_MESSAGE "Enable GEOS Unit Tests build")
set(STATUS_RESULT "OFF")

if(GEOS_ENABLE_TESTS)
  include_directories(${CMAKE_SOURCE_DIR}/capi)
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/tut)
  include_directories(${CMAKE_CURRENT_SOURCE_DIR})

  file(GLOB_RECURSE geos_unit_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

  add_executable(geos_unit ${geos_unit_SOURCES})
  if(OSX_FRAMEWORK)
      target_link_libraries(geos_unit ${PROJECT_NAME})
  else()
      target_link_libraries(geos_unit ${PROJECT_NAME} ${PROJECT_NAME}_c)
  endif()

  set_property(TARGET geos_unit PROPERTY CXX_STANDARD 11)

  add_test(geos_unit ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/geos_unit)

  set(STATUS_RESULT "ON")
endif()

if(NOT SUPPRESS_VERBOSE_OUTPUT)
message(STATUS "${STATUS_MESSAGE} - ${STATUS_RESULT}")
endif()

#################################################################################
# Group source files for IDE source explorers (e.g. Visual Studio)
#################################################################################
GenerateSourceGroups(tests/unit)
