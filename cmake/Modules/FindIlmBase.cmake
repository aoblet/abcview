##-*****************************************************************************
##
## Copyright (c) 2009-2016,
##  Sony Pictures Imageworks Inc. and
##  Industrial Light & Magic, a division of Lucasfilm Entertainment Company Ltd.
##
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are
## met:
## *       Redistributions of source code must retain the above copyright
## notice, this list of conditions and the following disclaimer.
## *       Redistributions in binary form must reproduce the above
## copyright notice, this list of conditions and the following disclaimer
## in the documentation and/or other materials provided with the
## distribution.
## *       Neither the name of Industrial Light & Magic nor the names of
## its contributors may be used to endorse or promote products derived
## from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
## "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
## A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
## OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
## LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
## DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
## THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
##-*****************************************************************************

IF (NOT ILMBASE_ROOT AND NOT $ENV{ILMBASE_ROOT} STREQUAL "")
    SET(ILMBASE_ROOT $ENV{ILMBASE_ROOT})
ENDIF()

IF (NOT DEFINED ILMBASE_ROOT)
    MESSAGE("ILMBASE_ROOT is undefined")
    IF (${CMAKE_HOST_UNIX})
        IF (${DARWIN})
          # TODO: set to default install path when shipping out
          SET(ILMBASE_ROOT NOTFOUND)
        ELSE()
          # TODO: set to default install path when shipping out
          SET(ILMBASE_ROOT "/usr/local/ilmbase-1.0.1/")
        ENDIF()
    ELSE()
        IF (${WINDOWS})
          # TODO: set to 32-bit or 64-bit path
          SET(ILMBASE_ROOT "C:/Program Files (x86)/ilmbase-1.0.1/")
        ELSE()
          SET(ILMBASE_ROOT NOTFOUND)
        ENDIF()
    ENDIF()
ELSE()
    SET(ILMBASE_ROOT ${ILMBASE_ROOT})
ENDIF()

SET(_ilmbase_FIND_COMPONENTS
    Iex
    IlmThread
    Imath
)

SET(_ilmbase_SEARCH_DIRS
    ${ILMBASE_ROOT}
    ~/Library/Frameworks
    /Library/Frameworks
    /usr/local
    /usr
    /sw
    /opt/local
    /opt/csw
    /opt
    /usr/freeware
)

FIND_PATH(ILMBASE_INCLUDE_DIR
  NAMES
    IlmBaseConfig.h
  HINTS
    ${_ilmbase_SEARCH_DIRS}
  PATH_SUFFIXES
    include
    include/OpenEXR
)

# If the headers were found, get the version from config file, if not already set.
IF (ILMBASE_INCLUDE_DIR)
  SET(ILMBASE_INCLUDE_DIRECTORY ${ILMBASE_INCLUDE_DIR})
  IF (NOT ILMBASE_VERSION)

    FIND_FILE(_ilmbase_CONFIG
      NAMES
        IlmBaseConfig.h
      PATHS
        "${ILMBASE_INCLUDE_DIR}"
        "${ILMBASE_INCLUDE_DIR}/OpenEXR"
   )

    IF (_ilmbase_CONFIG)
      FILE(STRINGS "${_ilmbase_CONFIG}" ILMBASE_BUILD_SPECIFICATION
           REGEX "^[ \t]*#define[ \t]+ILMBASE_VERSION_STRING[ \t]+\"[.0-9]+\".*$")
    ELSE()
      MESSAGE(WARNING "Could not find \"OpenEXRConfig.h\" in \"${ILMBASE_INCLUDE_DIR}\"")
    ENDIF()

    IF (ILMBASE_BUILD_SPECIFICATION)
      MESSAGE(STATUS "${ILMBASE_BUILD_SPECIFICATION}")
      STRING(REGEX REPLACE ".*#define[ \t]+ILMBASE_VERSION_STRING[ \t]+\"([.0-9]+)\".*"
             "\\1" _ilmbase_libs_ver_init ${ILMBASE_BUILD_SPECIFICATION})
    ELSE()
      MESSAGE(WARNING "Could not determine ILMBase library version, assuming ${_ilmbase_libs_ver_init}.")
    ENDIF()

    UNSET(_ilmbase_CONFIG CACHE)

  ENDIF()

  SET("ILMBASE_VERSION" ${_ilmbase_libs_ver_init} CACHE STRING "Version of OpenEXR lib")
  UNSET(_ilmbase_libs_ver_init)

  STRING(REGEX REPLACE "([0-9]+)[.]([0-9]+).*" "\\1_\\2" _ilmbase_libs_ver ${ILMBASE_VERSION})
ENDIF()

SET(_ilmbase_LIBRARIES)
FOREACH(COMPONENT ${_ilmbase_FIND_COMPONENTS})
  STRING(TOUPPER ${COMPONENT} UPPERCOMPONENT)

  FIND_LIBRARY(ILMBASE_${UPPERCOMPONENT}_LIB
    NAMES
      ${COMPONENT}-${_ilmbase_libs_ver} ${COMPONENT} 
    HINTS
      ${_ilmbase_SEARCH_DIRS}
    PATH_SUFFIXES
      lib64 lib
   )
  LIST(APPEND _ilmbase_LIBRARIES "${ILMBASE_${UPPERCOMPONENT}_LIBRARY}")
ENDFOREACH()

UNSET(_ilmbase_libs_ver)

IF (${ILMBASE_HALF_LIB} STREQUAL "ILMBASE_HALF_LIB-NOTFOUND")
    MESSAGE(FATAL_ERROR "ilmbase libraries (Half, Iex, IlmThread, Imath) not found, required")
ENDIF()

IF (${ILMBASE_IEX_LIB} STREQUAL "ILMBASE_IEX_LIB-NOTFOUND")
    MESSAGE(FATAL_ERROR "ilmbase libraries (Half, Iex, IlmThread, Imath) not found, required")
ENDIF()

IF (DEFINED USE_IEXMATH AND USE_IEXMATH)
    IF (${ILMBASE_IEXMATH_LIB} STREQUAL "ILMBASE_IEXMATH_LIB-NOTFOUND")
	  MESSAGE(FATAL_ERROR "ilmbase libraries (Half, Iex, IexMath, IlmThread, Imath) not found, required")
    ENDIF()
ENDIF()

IF (${ILMBASE_ILMTHREAD_LIB} STREQUAL "ILMBASE_ILMTHREAD_LIB-NOTFOUND")
    MESSAGE(FATAL_ERROR "ilmbase libraries (Half, Iex, IlmThread, Imath) not found, required")
ENDIF()

IF (${ILMBASE_IMATH_LIB} STREQUAL "ILMBASE_IMATH_LIB-NOTFOUND")
    MESSAGE(FATAL_ERROR "ilmbase libraries (Half, Iex, IlmThread, Imath) not found, required")
ENDIF()

IF (${ILMBASE_INCLUDE_DIRECTORY} STREQUAL "ILMBASE_INCLUDE_DIRECTORY-NOTFOUND")
    MESSAGE(FATAL_ERROR "ilmbase header files not found, required: ILMBASE_ROOT: ${ILMBASE_ROOT}")
ENDIF()

MESSAGE(STATUS "ILMBASE INCLUDE PATH: ${ILMBASE_INCLUDE_DIRECTORY}")
MESSAGE(STATUS "HALF LIB: ${ILMBASE_HALF_LIB}")
MESSAGE(STATUS "IEX LIB: ${ILMBASE_IEX_LIB}")
MESSAGE(STATUS "IEXMATH LIB: ${ILMBASE_IEXMATH_LIB}")
MESSAGE(STATUS "ILMTHREAD LIB: ${ILMBASE_ILMTHREAD_LIB}")
MESSAGE(STATUS "IMATH LIB: ${ILMBASE_IMATH_LIB}")

SET(ILMBASE_FOUND TRUE)
SET(ILMBASE_LIBS
    ${ILMBASE_IMATH_LIB}
    ${ILMBASE_ILMTHREAD_LIB}
    ${ILMBASE_IEX_LIB}
    ${ILMBASE_IEXMATH_LIB}
    ${ILMBASE_HALF_LIB}
)


