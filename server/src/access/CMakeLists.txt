file(GLOB SRC *.h *.cpp ../common/*.h)
SET(OBJ access)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
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
    /usr/local/log4cxx/lib
    /usr/local/lib
    /usr/local/mysql/lib
    )
LINK_LIBRARIES(
    co
    pb
    log4cxx
    json
    z
    lua
    mysqlclient
    )

#REMOVE_DEFINITIONS("-g")
#ADD_DEFINITIONS("-O2")

ADD_EXECUTABLE(${OBJ} ${SRC})
