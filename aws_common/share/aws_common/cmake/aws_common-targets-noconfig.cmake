#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "aws_common" for configuration ""
set_property(TARGET aws_common APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(aws_common PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libaws_common.so"
  IMPORTED_SONAME_NOCONFIG "libaws_common.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS aws_common )
list(APPEND _IMPORT_CHECK_FILES_FOR_aws_common "${_IMPORT_PREFIX}/lib/libaws_common.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
