file(GLOB SRC *.h ../common/*.h fightsvr.cpp master.cpp method.cpp
                             fightlogcache.cpp fight_method.cpp )
SET(OBJ fightsvr)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    ${CMAKE_CURRENT_SOURCE_DIR}/../public
    /usr/local/include/
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    )
LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    ${CMAKE_CURRENT_BINARY_DIR}/../public
    /usr/local/log4cxx/lib
    /usr/local/lib
    )
LINK_LIBRARIES(
    co
    log4cxx
    json
    z
    pb
    )

#REMOVE_DEFINITIONS("-g")
#ADD_DEFINITIONS("-O2")
ADD_EXECUTABLE(${OBJ} ${SRC})
