function(lg_setup_module
    bound_library
    python_native_module_name
    python_wrapper_module_name
    )
    # Parameters explanation, with an example: let's say we want to build binding for a C++ library named "foolib",
    #
    #    bound_library               : name of the C++ for which we build bindings ("foolib")
    #    python_native_module_name   : name of the native python module that provides bindings (for example "_foolib")
    #    python_wrapper_module_name  : name of the standard python module that will import the native module (for example "foolib")

    target_link_libraries(${python_native_module_name} PRIVATE ${bound_library})

    # Set python_native_module_name install path to "." (required by skbuild)
    install(TARGETS ${python_native_module_name} DESTINATION .)
    # Copy the python module to the project dir post build (for editable mode)
    set(module_built_shared_library_dest ${CMAKE_CURRENT_SOURCE_DIR}/bindings/${python_wrapper_module_name}/$<TARGET_FILE_NAME:${python_native_module_name}>)
    add_custom_target(
        ${python_native_module_name}_deploy_editable
        COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:${python_native_module_name}>
        ${module_built_shared_library_dest}
        DEPENDS ${python_native_module_name}
    )

    #
    # Set the rpath for Linux and  MacOS (see https://github.com/pybind/cmake_example/issues/11)
    #

    # rpath for the native python module: the bound_library should be installed in the lib/ subfolder
    install(TARGETS ${bound_library} DESTINATION ./lib/)
    lg_target_set_rpath(${python_native_module_name} "lib")

    # rpath for the bound library: the bound library is in the lib/ subfolder,
    # and, if it needs additional libraries, it should look for them in the same subfolder
    lg_target_set_rpath(${bound_library} ".")

    # On Windows, install DLLs in install folder root
    lg_target_install_linked_dlls_in_same_folder(${python_native_module_name})
endfunction()