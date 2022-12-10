set(lg_incremental_counter 0 CACHE INTERNAL "lg_incremental_counter")
macro(lg_increment_counter)
    math(EXPR next_value "${lg_incremental_counter} + 1")
    # message("lg_increment_counter => lg_incremental_counter=${lg_incremental_counter} next_value=${next_value} before set")
    set(lg_incremental_counter ${next_value} CACHE INTERNAL "lg_incremental_counter")
    # message("lg_increment_counter => lg_incremental_counter=${lg_incremental_counter} after set")
endmacro()

function (lg_copy_target_output_to_python_wrapper_folder_with_custom_name
    python_wrapper_module_name
    target_name
    target_custom_name
    )
    set(target_file_full_path $<TARGET_FILE:${target_name}>)
    set(python_wrapper_folder ${PROJECT_SOURCE_DIR}/bindings/${python_wrapper_module_name})
    set(target_dest ${python_wrapper_folder}/${target_custom_name})
    lg_increment_counter()
    set(custom_target_name ${python_wrapper_module_name}_${target_name}_${lg_incremental_counter}_deploy_editable)

    add_custom_target(
        ${custom_target_name}
        ALL
        COMMAND ${CMAKE_COMMAND} -E copy ${target_file_full_path} ${target_dest}
        DEPENDS ${python_native_module_name}
    )
endfunction()


function (lg_copy_target_output_to_python_wrapper_folder
    python_wrapper_module_name
    target_name
    )
    set(target_filename $<TARGET_FILE_NAME:${target_name}>)
    lg_copy_target_output_to_python_wrapper_folder_with_custom_name(
        ${python_wrapper_module_name}
        ${target_name}
        ${target_filename}
    )
endfunction()


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
    lg_copy_target_output_to_python_wrapper_folder(${python_wrapper_module_name} ${python_native_module_name})
endfunction()