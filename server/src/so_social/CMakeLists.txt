file(GLOB SRC *.h *.cpp
    ../common/weedong/core/seq/seq.cpp
    ../common/weedong/core/bstream/bstream.cpp
    ../common/*.h
    ../common/resource/r_basedata.cpp
    ../common/resource/r_market*.cpp
    ../common/local.cpp
    ../common/remote.cpp
    ../common/output.cpp )
SET(OBJ so_social)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}/../socialsvr
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    ${CMAKE_CURRENT_SOURCE_DIR}/../public
    /usr/local/include/
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    /usr/local/mysql/include
    )

LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    ${CMAKE_CURRENT_BINARY_DIR}/../public
    )

LINK_LIBRARIES(
    pb
    )

ADD_DEFINITIONS("-fPIC" -DBUILDING_DLL)

#REMOVE_DEFINITIONS("-g")
#ADD_DEFINITIONS("-O2")

ADD_LIBRARY(${OBJ}_shared SHARED ${SRC})
SET_TARGET_PROPERTIES(${OBJ}_shared PROPERTIES CLEAN_DIRECT_OUTPUT 1)
SET_TARGET_PROPERTIES(${OBJ}_shared PROPERTIES OUTPUT_NAME ${OBJ})
#SET_TARGET_PROPERTIES(${OBJ}_shared PROPERTIES VERSION 1.0.0 SOVERSION 1.0.0 )

