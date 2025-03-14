cmake_minimum_required(VERSION 3.10)
project(sqlite_vec C)

option(OMIT_SIMD "Omit SIMD flags" OFF)

find_program(PYTHON "python3")

# Get version and commit info
execute_process(COMMAND git log -n 1 --pretty=format:%H OUTPUT_VARIABLE SOURCE OUTPUT_STRIP_TRAILING_WHITESPACE WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")
string(TIMESTAMP DATE "%Y-%m-%dT%H:%M:%S" UTC)
file(READ VERSION VERSION)

string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" _match ${VERSION})
set(VERSION_MAJOR ${CMAKE_MATCH_1})
set(VERSION_MINOR ${CMAKE_MATCH_2})
set(VERSION_PATCH ${CMAKE_MATCH_3})

# Check system platform
if(APPLE)
    set(CONFIG_DARWIN YES)
elseif(WIN32)
    set(CONFIG_WINDOWS YES)
else()
    set(CONFIG_LINUX YES)
endif()

# Configure version header
configure_file(sqlite-vec.h.tmpl sqlite-vec.h)

# Add source files
set(SOURCE_FILES sqlite-vec.c sqlite-vec.h)

# Create targets
function(add_lib_internal TYPE TARGET)
    # SIMD flags for specific systems
    if(NOT OMIT_SIMD)
        if(APPLE AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
            target_compile_definitions(${TARGET} PUBLIC SQLITE_VEC_ENABLE_AVX)
            target_compile_options(${TARGET} PUBLIC -mavx)
        elseif(APPLE AND CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
            target_compile_definitions(${TARGET} PUBLIC SQLITE_VEC_ENABLE_NEON)
            target_compile_options(${TARGET} PUBLIC -mcpu=apple-m1)
        endif()
    endif()

    if(CONFIG_LINUX)
        target_compile_options(${TARGET} PRIVATE -O3 -fPIC)
    endif()

    if("${TYPE}" STREQUAL "STATIC")
        target_link_libraries(${TARGET} PUBLIC sqlite3-static)
    else()
        target_link_libraries(${TARGET} PUBLIC "$<LINK_LIBRARY:WHOLE_ARCHIVE,sqlite3-static>")
    endif()

    target_include_directories(${TARGET}
        PUBLIC ${CMAKE_CURRENT_LIST_DIR}/
        PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/)
endfunction()

add_library(sqlite_vec_shared SHARED ${SOURCE_FILES})
set_target_properties(sqlite_vec_shared PROPERTIES OUTPUT_NAME "vec0")

if(WIN32)
    set_target_properties(sqlite_vec_shared PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

target_compile_definitions(sqlite_vec_shared PUBLIC SQLITE_CORE SQLITE_VEC_SHARED)
add_lib_internal("SHARED" sqlite_vec_shared)

add_library(sqlite_vec_static STATIC ${SOURCE_FILES})
target_compile_definitions(sqlite_vec_static PUBLIC SQLITE_CORE SQLITE_VEC_STATIC)
add_lib_internal("STATIC" sqlite_vec_static)

# # Define cli target
# add_executable(sqlite3_cli examples/sqlite3-cli/core_init.c)
# target_compile_definitions(sqlite3_cli PRIVATE SQLITE_CORE SQLITE_VEC_STATIC SQLITE_THREADSAFE=0 SQLITE_ENABLE_FTS4 SQLITE_ENABLE_STMT_SCANSTATUS SQLITE_ENABLE_BYTECODE_VTAB SQLITE_ENABLE_EXPLAIN_COMMENTS SQLITE_EXTRA_INIT=core_init)
# target_include_directories(sqlite3_cli PRIVATE vendor ./)
# target_link_libraries(sqlite3_cli PRIVATE sqlite_vec_static sqlite3)