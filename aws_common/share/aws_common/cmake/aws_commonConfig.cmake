set(AWS_COMMON_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..)

set(AWSSDK_ROOT_DIR ${AWS_COMMON_ROOT_DIR})
include("${CMAKE_CURRENT_LIST_DIR}/AWSSDKConfig.cmake")

# Compute paths
set(aws_common_INCLUDE_DIRS "${AWS_COMMON_ROOT_DIR}/include")

if(NOT TARGET aws_common)
  include("${CMAKE_CURRENT_LIST_DIR}/aws_common-targets.cmake")
endif()

set(aws_common_LIB_DIR "${AWS_COMMON_ROOT_DIR}/lib")
set(aws_common_LIBRARIES aws_common aws-cpp-sdk-core;aws-cpp-sdk-logs;aws-cpp-sdk-monitoring;aws-cpp-sdk-s3;aws-cpp-sdk-kinesis;aws-cpp-sdk-iot;aws-cpp-sdk-lex;aws-cpp-sdk-polly)

# Imported packages which the current package intends to export.
foreach(_imported_library aws-cpp-sdk-core;aws-cpp-sdk-logs;aws-cpp-sdk-monitoring;aws-cpp-sdk-s3;aws-cpp-sdk-kinesis;aws-cpp-sdk-iot;aws-cpp-sdk-lex;aws-cpp-sdk-polly)
 if(NOT TARGET ${_imported_library})
  add_library(${_imported_library} SHARED IMPORTED)
  set_target_properties(${_imported_library} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${aws_common_INCLUDE_DIRS}
  )
  set_property(TARGET ${_imported_library} APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
  set_target_properties(${_imported_library} PROPERTIES
    IMPORTED_LOCATION_NOCONFIG "${aws_common_LIB_DIR}/lib${_imported_library}.so"
    IMPORTED_SONAME_NOCONFIG "lib${_imported_library}.so"
  )
 endif()
endforeach()

# where the .pc pkgconfig files are installed
set(aws_common_PKGCONFIG_DIR "${AWS_COMMON_ROOT_DIR}/lib/pkgconfig")

# where the DefineTestMacros are located
include("${CMAKE_CURRENT_LIST_DIR}/DefineTestMacros.cmake")
