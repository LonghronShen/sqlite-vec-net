if(WIN32)
    add_compile_definitions("_CRT_SECURE_NO_WARNINGS")

    if(MSVC)
        include(Platform/Windows-MSVC)

        message(STATUS "MSVC_CXX_ARCHITECTURE_ID: ${MSVC_CXX_ARCHITECTURE_ID}")
        message(STATUS "MSVC_CXX_ARCHITECTURE_FAMILY: ${MSVC_CXX_ARCHITECTURE_FAMILY}")

        if(MSVC_CXX_ARCHITECTURE_ID MATCHES "^ARM")
            set(CMAKE_SYSTEM_PROCESSOR ${MSVC_CXX_ARCHITECTURE_ID})
        endif()

        add_compile_options("/source-charset:utf-8")

        if(CMAKE_BUILD_TYPE STREQUAL "Debug")
            add_compile_options("/MTd")
        else()
            add_compile_options("/MT")
        endif()

        set(CompilerFlags
            CMAKE_CXX_FLAGS
            CMAKE_CXX_FLAGS_DEBUG
            CMAKE_CXX_FLAGS_RELEASE
            CMAKE_CXX_FLAGS_MINSIZEREL
            CMAKE_CXX_FLAGS_RELWITHDEBINFO
            CMAKE_C_FLAGS
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_RELEASE
            CMAKE_C_FLAGS_MINSIZEREL
            CMAKE_C_FLAGS_RELWITHDEBINFO)

        foreach(CompilerFlag ${CompilerFlags})
            string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
            set(${CompilerFlag} "${${CompilerFlag}}" CACHE STRING "msvc compiler flags" FORCE)
            message("MSVC flags: ${CompilerFlag}:${${CompilerFlag}}")
        endforeach()
    elseif(MINGW)
        add_compile_definitions("WIN32" "_WIN32")
    endif()
else()
    if(UNIX)
        if(APPLE)
            add_compile_options("-fPIC" "-march=native")

            if(CMAKE_BUILD_TYPE STREQUAL "Debug")
                add_compile_options("-g" "-O0")
            else()
                add_compile_options("-O3")
            endif()

            set(CMAKE_MACOSX_RPATH 1 CACHE STRING "CMAKE_MACOSX_RPATH" FORCE)
            option(DISABLE_COTIRE "DISABLE_COTIRE" on)

            if(DISABLE_COTIRE)
                set(__COTIRE_INCLUDED TRUE CACHE BOOL "__COTIRE_INCLUDED" FORCE)

                function(cotire)
                endfunction()
            endif()
        else()
            if(CMAKE_COMPILER_IS_GNUCC AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 8.4)
                message(FATAL_ERROR "GCC version must be at least 8.4!")
            endif()

            add_compile_options("-fPIC")

            if(CMAKE_BUILD_TYPE STREQUAL "Debug")
                add_compile_options("-g")
            else()
                # add_compile_options("-O3")
            endif()

            if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm" OR ${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64")
                set(PLATFORM_ID "linux-arm")
            endif()

            # if(CMAKE_SYSTEM_PROCESSOR MATCHES "(x86)|(X86)|(amd64)|(AMD64)")
            # add_compile_options("-m64" "-march=westmere")
            # endif()
        endif()
    endif()
endif()

include(CheckIncludeFile)

check_include_file("experimental/iterator" HAS_EXPERIMENTAL_ITERATOR_H LANGUAGE cxx)

macro(cleanup_interface_include_directories TARGET)
    get_target_property(original_interface_incs ${TARGET} INTERFACE_INCLUDE_DIRECTORIES)
    set(final_interface_incs "")

    foreach(inc ${original_interface_incs})
        if("${inc}" MATCHES "^(${CMAKE_CURRENT_SOURCE_DIR}|${CMAKE_CURRENT_BINARY_DIR})")
            continue()
        endif()

        list(APPEND final_interface_incs ${inc})
    endforeach()

    set_target_properties(${TARGET} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${final_interface_incs}")
    unset(final_interface_incs)
endmacro()