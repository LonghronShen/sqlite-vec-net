project(${project_name}-lib C CXX)

file(GLOB_RECURSE src
    ${CMAKE_CURRENT_LIST_DIR}/*.h
    ${CMAKE_CURRENT_LIST_DIR}/*.hpp

    ${CMAKE_CURRENT_LIST_DIR}/*.c
    ${CMAKE_CURRENT_LIST_DIR}/*.cc
    ${CMAKE_CURRENT_LIST_DIR}/*.cpp
)

file(GLOB_RECURSE public_headers
    ${CMAKE_CURRENT_LIST_DIR}/include/public/*.h
    ${CMAKE_CURRENT_LIST_DIR}/include/public/*.hpp
)

# =================================================================
if(HAS_EXPERIMENTAL_ITERATOR_H)
    set(HAS_EXPERIMENTAL_ITERATOR_H 1)
else()
    set(HAS_EXPERIMENTAL_ITERATOR_H 0)
endif()

# =================================================================
include(CMakeParseArguments)

function(add_lib_internal)
    set(options "")
    set(oneValueArgs TYPE ALIAS OUTPUT_LIB_NAME)
    set(multiValueArgs "")
    cmake_parse_arguments(ADD_LIB_INTERNAL "${options}" "${oneValueArgs}"
        "${multiValueArgs}" ${ARGN})

    set(type "${ADD_LIB_INTERNAL_TYPE}")
    set(alias "${ADD_LIB_INTERNAL_ALIAS}")
    set(output_lib_name "${ADD_LIB_INTERNAL_OUTPUT_LIB_NAME}")

    string(TOLOWER "${type}" suffix)
    set(internal_lib_name ${project_name}-${suffix}-lib)

    message(STATUS "Adding library for '${internal_lib_name}' with alias as '${alias}'")

    if("${type}" STREQUAL "STATIC")
        add_library(${internal_lib_name}
            STATIC ${src}
        )
    else()
        add_library(${internal_lib_name}
            SHARED ${src}
        )

        set_target_properties(${internal_lib_name} PROPERTIES
            WINDOWS_EXPORT_ALL_SYMBOLS ON
            POSITION_INDEPENDENT_CODE ON
        )
    endif()

    if(output_lib_name)
        set_target_properties(${internal_lib_name} PROPERTIES OUTPUT_NAME ${output_lib_name})
        set_target_properties(${internal_lib_name} PROPERTIES PREFIX "")
    endif()

    if(NOT(alias STREQUAL ""))
        add_library(${alias} ALIAS ${internal_lib_name})
    endif()

    target_include_directories(${internal_lib_name}
        PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include/public"
        PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include/private"
    )

    target_link_libraries(${internal_lib_name}
        PUBLIC "$<LINK_LIBRARY:WHOLE_ARCHIVE,sqlite_vec_static>"
    )

    if(WIN32 AND MSVC)
        if("${type}" STREQUAL "SHARED")
            add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/sqlite_vec_static.def"
                DEPENDS $<TARGET_OBJECTS:sqlite_vec_static>
                COMMAND ${CMAKE_COMMAND} ARGS -P "${SQLITE_VEC_CMAKE_MODULE_PATH}/write_file.cmake" "$<TARGET_OBJECTS:sqlite_vec_static>" "${CMAKE_CURRENT_BINARY_DIR}/sqlite_vec_static.objs" VERBATIM
                COMMAND ${CMAKE_COMMAND} ARGS -E __create_def "${CMAKE_CURRENT_BINARY_DIR}/sqlite_vec_static.def" "${CMAKE_CURRENT_BINARY_DIR}/sqlite_vec_static.objs" VERBATIM
            )
            target_sources(${internal_lib_name} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/sqlite_vec_static.def")
        endif()
    endif()
endfunction()

# =================================================================
add_lib_internal(TYPE SHARED ALIAS sqlite_vec::sqlite_vec_ex::shared OUTPUT_LIB_NAME libvec0ex)

add_lib_internal(TYPE STATIC ALIAS sqlite_vec::sqlite_vec_ex)

make_runtime_native_nupkg(sqlite-vec-cpp-shared-lib
    "${SQLITE_VEC_NUGET_PACKAGE_NAMESPACE}"
    "runtime.native.${CMAKE_CXX_COMPILER_ID}")
