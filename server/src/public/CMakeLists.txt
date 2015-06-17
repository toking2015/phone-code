file(GLOB SRC *.h *.c *.cpp
    ../common/proto/*.cpp ../common/proto/transfrom/*.cpp
    )
SET(OBJ pb)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    /usr/local/mysql/include/mysql
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    /usr/local/mysql/include
    ../common
    )

ADD_DEFINITIONS("-fPIC")

#REMOVE_DEFINITIONS("-g")
#ADD_DEFINITIONS("-O2")

ADD_LIBRARY(${OBJ}_static STATIC ${SRC})
SET_TARGET_PROPERTIES(${OBJ}_static PROPERTIES CLEAN_DIRECT_OUTPUT 1)
SET_TARGET_PROPERTIES(${OBJ}_static PROPERTIES OUTPUT_NAME ${OBJ})
