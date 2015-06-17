file(GLOB SRC *.h ../common/*.h *.cpp
                             )
SET(OBJ robotsvr)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    ${CMAKE_CURRENT_SOURCE_DIR}/../public
    /usr/local/include/
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    /usr/local/curl/include
    )
LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    ${CMAKE_CURRENT_BINARY_DIR}/../public
    /usr/local/log4cxx/lib
    /usr/local/lib
    /usr/local/curl/lib
    )
LINK_LIBRARIES(
    co
    log4cxx
    json
    curl
    z
    pb
    )

ADD_EXECUTABLE(${OBJ} ${SRC})
