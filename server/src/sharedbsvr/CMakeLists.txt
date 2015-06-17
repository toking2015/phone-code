file(GLOB SRC *.h ../common/*.h sharedbsvr.cpp master.cpp sql.cpp )
SET(OBJ sharedbsvr)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    /usr/local/include/
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    /usr/local/mysql/include
    )
LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    /usr/local/log4cxx/lib
    /usr/local/lib
    /usr/local/mysql/lib
    )
LINK_LIBRARIES(
    co
    log4cxx
    json
    z
    mysqlclient
    )

#REMOVE_DEFINITIONS("-g")
#ADD_DEFINITIONS("-O2")

ADD_EXECUTABLE(${OBJ} ${SRC})
