
set(_THIS_MODULE_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# This will create an imgui target with the correct install, include and link options
function(add_imgui_target imgui_dir)
    if(NOT TARGET imgui)
        file(GLOB imgui_sources ${imgui_dir}/*.h ${imgui_dir}/*.cpp)
        add_library(imgui SHARED ${imgui_sources})
        target_include_directories(imgui PUBLIC ${imgui_dir})
        target_compile_definitions(imgui PRIVATE IMGUI_USER_CONFIG="${_THIS_MODULE_BASE_DIR}/add_imgui_target_imconfig.h")

        install(TARGETS imgui DESTINATION ./lib/)
    endif()
endfunction()
