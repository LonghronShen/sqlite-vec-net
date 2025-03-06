project(${project_name}-exe C CXX)

file(GLOB_RECURSE SRC
    ${CMAKE_CURRENT_LIST_DIR}/*.h
    ${CMAKE_CURRENT_LIST_DIR}/*.hpp
    ${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

check_function_exists(system _HAVE_SYSTEM)
if(NOT _HAVE_SYSTEM)
    set(SQLITE3_SHELL_DEFS SQLITE_NOHAVE_SYSTEM=1)
endif()

add_executable(${project_name}-exe ${SRC} ${sqlite_amalgamation_SOURCE_DIR}/shell.c)
target_compile_definitions(${project_name}-exe PRIVATE ${SQLITE3_SHELL_DEFS})
target_link_libraries(${project_name}-exe
    sqlite_vec_static
    sqlite3-static
    ${SQLITE3_DEP_LIBRARIES})

if(MINGW)
    mingw_bundle_dll(${project_name}-exe)
endif()
