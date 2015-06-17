file(GLOB SRC *.h *.c *.cpp
    zlib/*.c
    weedong/core/os.cpp
    weedong/core/seq/seq.cpp
    weedong/core/bstream/bstream.cpp
    weedong/core/dispatch/tasklist.cpp
    weedong/core/dispatch/disp.cpp
    weedong/core/sql/sql.cpp
    )
SET(OBJ co)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    /usr/local/mysql/include/mysql
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    /usr/local/mysql/include
    )

ADD_DEFINITIONS("-fPIC")

#REMOVE_DEFINITIONS("-g")
#ADD_DEFINITIONS("-O2")

#ADD_LIBRARY(${OBJ}_shared SHARED ${SRC})
ADD_LIBRARY(${OBJ}_static STATIC ${SRC})
#SET_TARGET_PROPERTIES(${OBJ}_shared PROPERTIES CLEAN_DIRECT_OUTPUT 1)
SET_TARGET_PROPERTIES(${OBJ}_static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
#SET_TARGET_PROPERTIES(${OBJ}_shared PROPERTIES OUTPUT_NAME ${OBJ})
SET_TARGET_PROPERTIES(${OBJ}_static PROPERTIES OUTPUT_NAME ${OBJ})
#SET_TARGET_PROPERTIES(${OBJ}_shared PROPERTIES VERSION 1.0.0 SOVERSION 1.0.0)
