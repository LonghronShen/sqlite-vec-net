find_package(Threads REQUIRED)

if(UNIX)
  find_package(DL REQUIRED)
endif()

set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE STRING "FETCHCONTENT_UPDATES_DISCONNECTED" FORCE)

include(FetchContent)

macro(install)
endmacro()

# # cmrc
# FetchContent_Declare(cmrc
# GIT_REPOSITORY https://github.com/vector-of-bool/cmrc.git
# GIT_TAG a64bea50c05594c8e7cf1f08e441bb9507742e2e)

# FetchContent_GetProperties(cmrc)

# if(NOT cmrc_POPULATED)
# FetchContent_Populate(cmrc)
# add_subdirectory(${cmrc_SOURCE_DIR} ${cmrc_BINARY_DIR} EXCLUDE_FROM_ALL)
# endif()

# # nlohmann_json
# FetchContent_Declare(json
# GIT_REPOSITORY https://github.com/ArthurSonzogni/nlohmann_json_cmake_fetchcontent
# GIT_TAG v3.10.4)

# FetchContent_GetProperties(json)

# if(NOT json_POPULATED)
# FetchContent_Populate(json)
# add_subdirectory(${json_SOURCE_DIR} ${json_BINARY_DIR} EXCLUDE_FROM_ALL)
# endif()

# # argh
# FetchContent_Declare(argh
# GIT_REPOSITORY https://github.com/adishavit/argh.git
# GIT_TAG master)

# FetchContent_GetProperties(argh)

# if(NOT argh_POPULATED)
# FetchContent_Populate(argh)
# add_subdirectory(${argh_SOURCE_DIR} ${argh_BINARY_DIR} EXCLUDE_FROM_ALL)
# endif()

# sqlite-amalgamation
set(ENABLE_SHARED ON CACHE STRING "ENABLE_SHARED" FORCE)
set(ENABLE_STATIC ON CACHE STRING "ENABLE_STATIC" FORCE)
set(BUILD_SHELL ON CACHE STRING "BUILD_SHELL" FORCE)
set(ENABLE_STATIC_SHELL ON CACHE STRING "ENABLE_STATIC_SHELL" FORCE)
set(BUILD_WITH_XPSDK ON CACHE STRING "BUILD_WITH_XPSDK" FORCE)

FetchContent_Declare(sqlite_amalgamation
  GIT_REPOSITORY https://github.com/rhuijben/sqlite-amalgamation.git
  GIT_TAG master)

FetchContent_GetProperties(sqlite_amalgamation)

if(NOT sqlite_amalgamation_POPULATED)
  FetchContent_Populate(sqlite_amalgamation)
  add_subdirectory(${sqlite_amalgamation_SOURCE_DIR} ${sqlite_amalgamation_BINARY_DIR})

  if(WIN32)
    target_compile_definitions(sqlite3-static
      PUBLIC SQLITE_OS_WIN
      PUBLIC SQLITE_OS_WINNT
      PUBLIC SQLITE_USE_SEH)
    target_link_libraries(sqlite3-static PUBLIC rpcrt4.lib)
    set_target_properties(sqlite3-static PROPERTIES
      OUTPUT_NAME sqlite3_s
    )

    target_compile_definitions(sqlite3-shared
      PUBLIC SQLITE_OS_WIN
      PUBLIC SQLITE_OS_WINNT
      PUBLIC SQLITE_USE_SEH)
    target_link_libraries(sqlite3-shared rpcrt4.lib)
    set_target_properties(sqlite3-shared PROPERTIES
      WINDOWS_EXPORT_ALL_SYMBOLS ON
      OUTPUT_NAME libsqlite3
    )
  endif()

  target_include_directories(sqlite3-static BEFORE INTERFACE ${sqlite_amalgamation_SOURCE_DIR}/)
  target_include_directories(sqlite3-shared BEFORE INTERFACE ${sqlite_amalgamation_SOURCE_DIR}/)

  add_library(SQLite::SQLite3 ALIAS sqlite3-static)
endif()

# sqlite_vec
FetchContent_Declare(sqlite_vec
  GIT_REPOSITORY https://github.com/asg017/sqlite-vec.git
  GIT_TAG main)

FetchContent_GetProperties(sqlite_vec)

if(NOT sqlite_vec_POPULATED)
  FetchContent_Populate(sqlite_vec)
  file(COPY "${CMAKE_CURRENT_LIST_DIR}/patches/sqlite_vec/CMakeLists.txt" DESTINATION "${sqlite_vec_SOURCE_DIR}/")
  execute_process(
    COMMAND git apply "${CMAKE_CURRENT_LIST_DIR}/patches/sqlite_vec/patch_builtin_popcountl.patch"
    WORKING_DIRECTORY "${sqlite_vec_SOURCE_DIR}/")
  add_subdirectory(${sqlite_vec_SOURCE_DIR} ${sqlite_vec_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

if(MINGW)
  # mingw-bundledlls
  FetchContent_Declare(mingw_bundledlls
    GIT_REPOSITORY https://github.com/LonghronShen/mingw-bundledlls.git
    GIT_TAG master)

  FetchContent_GetProperties(mingw_bundledlls)

  if(NOT mingw_bundledlls_POPULATED)
    FetchContent_Populate(mingw_bundledlls)

    find_package(Python3 REQUIRED)

    get_filename_component(MINGW_COMPILER_HOME ${CMAKE_CXX_COMPILER} DIRECTORY)

    file(REAL_PATH "${MINGW_COMPILER_HOME}/../" TOOLCHAIN_DIR)
    file(REAL_PATH "${MINGW_COMPILER_HOME}/../../" MSYS_DIR)

    set(MINGW_BUNDLEDLLS_SEARCH_PATH "${TOOLCHAIN_DIR}|${MSYS_DIR}")
    message(STATUS "Searching MinGW DLLs in: \"${MINGW_BUNDLEDLLS_SEARCH_PATH}\"")

    function(mingw_bundle_dll target_name)
      add_custom_target(${target_name}-deps ALL
        COMMAND ${CMAKE_COMMAND} -E env MINGW_BUNDLEDLLS_SEARCH_PATH=${MINGW_BUNDLEDLLS_SEARCH_PATH} -- "${Python3_EXECUTABLE}" "${mingw_bundledlls_SOURCE_DIR}/mingw-bundledlls" -l "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/dependencies.log" --force --copy "$<TARGET_FILE:${target_name}>"
        WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/"
        DEPENDS ${target_name}
        COMMENT "Copying MinGW libs ..."
        VERBATIM
      )
    endfunction()
  endif()
endif()