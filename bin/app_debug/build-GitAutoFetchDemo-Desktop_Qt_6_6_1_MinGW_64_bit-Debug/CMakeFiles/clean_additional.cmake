# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\GitAutoFetchDemo_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\GitAutoFetchDemo_autogen.dir\\ParseCache.txt"
  "GitAutoFetchDemo_autogen"
  )
endif()
