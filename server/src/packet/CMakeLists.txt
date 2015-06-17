file(GLOB SRC *.cpp *.c *.h
    json/*.cpp )
SET(OBJ packet)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
    /usr/local/include/
    /usr/local/png/include/
    /usr/local/jpeg/include/
    )
LINK_DIRECTORIES(
    ${CMAKE_CURRENT_BINARY_DIR}/../common
    /usr/local/lib
    /usr/local/png/lib
    /usr/local/jpeg/lib
    )
LINK_LIBRARIES(
    co
    png
    jpeg
    )

ADD_EXECUTABLE(${OBJ} ${SRC})
