
find_path(FAAD2_INCLUDE_DIR faad.h)

find_library(FAAD2_LIBRARY libfaad.a)

find_package_handle_standard_args(FAAD2 DEFAULT_MSG FAAD2_INCLUDE_DIR FAAD2_LIBRARY)

if(FAAD2_FOUND)
	set(FAAD2_LIBRARIES ${FAAD2_LIBRARY})
	set(FAAD2_INCLUDE_DIRS ${FAAD2_INCLUDE_DIR})
endif()

mark_as_advanced(FAAD2_INCLUDE_DIR FAAD2_LIBRARY)
