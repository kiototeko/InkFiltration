# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
        cs_add_ci.cpp       cs_cumsum_ri.cpp     cs_ereach_ci.cpp  cs_ipvec_ri.cpp    cs_malloc_ci.cpp    cs_pinv_ri.cpp      cs_reach_ci.cpp    cs_symperm_ri.cpp    CXSparseAPI.cpp           getPeaksGlobal_initialize.cpp  rtGetInf.cpp
        cs_add_ri.cpp       cs_dfs_ci.cpp        cs_ereach_ri.cpp  cs_leaf_ci.cpp     cs_malloc_ri.cpp    cs_post_ci.cpp      cs_reach_ri.cpp    cs_tdfs_ci.cpp       eml_setop.cpp             getPeaksGlobal_terminate.cpp   rtGetNaN.cpp
        cs_amd_ci.cpp       cs_dfs_ri.cpp        cs_etree_ci.cpp   cs_leaf_ri.cpp     cs_maxtrans_ci.cpp  cs_post_ri.cpp      cs_scatter_ci.cpp  cs_tdfs_ri.cpp       envelope.cpp              rt_nonfinite.cpp
        cs_amd_ri.cpp       cs_dmperm_ci.cpp     cs_etree_ri.cpp   cs_load_ci.cpp     cs_maxtrans_ri.cpp  cs_print_ci.cpp     cs_scatter_ri.cpp  cs_transpose_ci.cpp  filter.cpp                getPeaksPre.cpp                solve_from_lu.cpp
        cs_chol_ci.cpp      cs_dmperm_ri.cpp     cs_fkeep_ci.cpp   cs_load_ri.cpp     cs_multiply_ci.cpp  cs_print_ri.cpp     cs_scc_ci.cpp      cs_transpose_ri.cpp  filtfilt.cpp              solve_from_qr.cpp
        cs_chol_ri.cpp      cs_droptol_ci.cpp    cs_fkeep_ri.cpp   cs_lsolve_ci.cpp   cs_multiply_ri.cpp  cs_pvec_ci.cpp      cs_scc_ri.cpp      cs_updown_ci.cpp     findpeaks.cpp             sort.cpp
        cs_cholsol_ci.cpp   cs_droptol_ri.cpp    cs_gaxpy_ci.cpp   cs_lsolve_ri.cpp   cs_norm_ci.cpp      cs_pvec_ri.cpp      cs_schol_ci.cpp    cs_updown_ri.cpp     getPeaksA.cpp             sortIdx.cpp
        cs_cholsol_ri.cpp   cs_dropzeros_ci.cpp  cs_gaxpy_ri.cpp   cs_ltsolve_ci.cpp  cs_norm_ri.cpp      cs_qr_ci.cpp        cs_schol_ri.cpp    cs_usolve_ci.cpp     sparse.cpp
        cs_compress_ci.cpp  cs_dropzeros_ri.cpp  cs_happly_ci.cpp  cs_ltsolve_ri.cpp  cs_operator_ci.cpp  cs_qr_ri.cpp        cs_spsolve_ci.cpp  cs_usolve_ri.cpp     heapsort.cpp
        cs_compress_ri.cpp  cs_dupl_ci.cpp       cs_happly_ri.cpp  cs_lu_ci.cpp       cs_operator_ri.cpp  cs_qrsol_ci.cpp     cs_spsolve_ri.cpp  cs_util_ci.cpp       insertionsort.cpp              unpackCXStruct.cpp
        cs_counts_ci.cpp    cs_dupl_ri.cpp       cs_house_ci.cpp   cs_lu_ri.cpp       cs_permute_ci.cpp   cs_qrsol_ri.cpp     cs_sqr_ci.cpp      cs_util_ri.cpp       introsort.cpp
        cs_counts_ri.cpp    cs_entry_ci.cpp      cs_house_ri.cpp   cs_lusol_ci.cpp    cs_permute_ri.cpp   cs_randperm_ci.cpp  cs_sqr_ri.cpp      cs_utsolve_ci.cpp    makeCXSparseMatrix.cpp
        cs_cumsum_ci.cpp    cs_entry_ri.cpp      cs_ipvec_ci.cpp   cs_lusol_ri.cpp    cs_pinv_ci.cpp      cs_randperm_ri.cpp  cs_symperm_ci.cpp  cs_utsolve_ri.cpp    getPeaksGlobal_data.cpp   native-lib.cpp

        )


target_include_directories(native-lib PUBLIC /home/kiototeko/tareas/masterThesis/PrinterLeaks/app/src/main/cpp)
target_compile_definitions(native-lib PUBLIC -DCS_COMPLEX PUBLIC -DMODEL=getpeaks)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library(log-lib log)

target_link_libraries(native-lib ${log-lib})
