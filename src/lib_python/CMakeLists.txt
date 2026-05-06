add_library(Sourcetrail_lib_python
	project/SourceGroupFactoryModulePython.h
	project/SourceGroupFactoryModulePython.cpp
	project/SourceGroupPythonEmpty.h
	project/SourceGroupPythonEmpty.cpp
)
setDefaultTargetOptions(Sourcetrail_lib_python)

target_include_directories(Sourcetrail_lib_python
	PUBLIC
		project
)

target_link_libraries(Sourcetrail_lib_python
	PUBLIC
		Sourcetrail_lib
)

add_custom_command(
	COMMAND ${CMAKE_COMMAND} -E echo "Downloading Python indexer"
	
	TARGET Sourcetrail_lib_python
	PRE_BUILD
	WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/scripts/"
	COMMAND ${BASH_COMMAND} download_python_indexer.sh ${CMAKE_BINARY_DIR}
)
