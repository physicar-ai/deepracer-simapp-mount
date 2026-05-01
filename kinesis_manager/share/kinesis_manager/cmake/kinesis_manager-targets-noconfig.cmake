#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "kinesis_manager" for configuration ""
set_property(TARGET kinesis_manager APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(kinesis_manager PROPERTIES
  IMPORTED_LINK_INTERFACE_LIBRARIES_NOCONFIG "aws-cpp-sdk-kinesis;aws-cpp-sdk-core;producer;log4cplus"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libkinesis_manager.so"
  IMPORTED_SONAME_NOCONFIG "libkinesis_manager.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS kinesis_manager )
list(APPEND _IMPORT_CHECK_FILES_FOR_kinesis_manager "${_IMPORT_PREFIX}/lib/libkinesis_manager.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
