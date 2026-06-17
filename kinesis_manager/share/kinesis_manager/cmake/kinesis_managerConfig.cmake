# Compute paths
set(kinesis_manager_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../include")

if(NOT TARGET kinesis_manager)
  include("${CMAKE_CURRENT_LIST_DIR}/kinesis_manager-targets.cmake")
endif()

set(kinesis_manager_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../lib")
set(kinesis_manager_LIBRARIES kinesis_manager producer)

# Imported packages which the current package intends to export.
foreach(_imported_library producer)
 if(NOT TARGET ${_imported_library})
  add_library(${_imported_library} SHARED IMPORTED)
  set_target_properties(${_imported_library} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${kinesis_manager_INCLUDE_DIRS}
  )
  set_property(TARGET ${_imported_library} APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
  set_target_properties(${_imported_library} PROPERTIES
    IMPORTED_LOCATION_NOCONFIG "${kinesis_manager_LIB_DIR}/lib${_imported_library}.so"
    IMPORTED_SONAME_NOCONFIG "lib${_imported_library}.so"
  )
 endif()
endforeach()

# where the .pc pkgconfig files are installed
set(kinesis_manager_PKGCONFIG_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../lib/pkgconfig")
