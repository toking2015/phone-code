file(GLOB SRC *.cpp *.c *.h
    ../common/weedong/core/seq/*.cpp
    ../common/weedong/core/bstream/bstream.cpp ) 
SET(OBJ proto)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    /usr/local/include/
    /usr/local/jsoncpp/include
    )
LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    /usr/local/lib
    )
LINK_LIBRARIES(
    )

ADD_EXECUTABLE(${OBJ} ${SRC})
