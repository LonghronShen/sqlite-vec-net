project(${project_name}-demo C CXX)

file(GLOB_RECURSE SRC
    ${CMAKE_CURRENT_LIST_DIR}/*.h
    ${CMAKE_CURRENT_LIST_DIR}/*.hpp
    ${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

add_executable(${project_name}-demo ${SRC})
target_link_libraries(${project_name}-demo sqlite3-static sqlite_vec_static ${CMAKE_THREAD_LIBS_INIT})

if(NEED_LINKING_AGAINST_LIBM)
    target_link_libraries(${project_name}-demo m)
endif()

if(MINGW)
    mingw_bundle_dll(${project_name}-demo)
endif()
