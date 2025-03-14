project(${project_name}-exe C CXX)

file(GLOB_RECURSE SRC
    ${CMAKE_CURRENT_LIST_DIR}/*.h
    ${CMAKE_CURRENT_LIST_DIR}/*.hpp
    ${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

target_sources(sqlite3 PRIVATE ${SRC})
target_link_libraries(sqlite3 sqlite3-static sqlite_vec_static)

add_executable(${project_name}-exe ALIAS sqlite3)

if(MINGW)
    mingw_bundle_dll(${project_name}-exe)
endif()
