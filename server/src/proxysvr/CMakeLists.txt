file(GLOB SRC *.cpp *.h ../commmon/*.h) 
SET(OBJ proxysvr)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    /usr/local/include/
    /usr/local/jsoncpp/include
    /usr/local/log4cxx/include
    )
LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    /usr/local/log4cxx/lib
    /usr/local/lib
    /usr/local/jsoncpp/libs/linux-gcc-4.1.2
    )
LINK_LIBRARIES(
    co
    log4cxx
    json_linux-gcc-4.1.2_libmt
    )

ADD_EXECUTABLE(${OBJ} ${SRC})
