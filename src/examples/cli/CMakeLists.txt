project(${project_name}-exe C CXX)

file(GLOB_RECURSE SRC
    ${CMAKE_CURRENT_LIST_DIR}/*.h
    ${CMAKE_CURRENT_LIST_DIR}/*.hpp
    ${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

add_executable(${project_name}-exe ${SRC})
target_link_libraries(${project_name}-exe 
    PRIVATE sqlite_vec_static
    PRIVATE sqlite3)

if(MINGW)
    mingw_bundle_dll(${project_name}-exe)
endif()
