# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "PDAL"
version = v"2.5.4"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/PDAL/PDAL.git", "4d01a1b9486ae84b42192a36999b42fb75d0715e"),
]

# Bash recipe for building across all platforms
script = raw"""

cd $WORKSPACE/srcdir/PDAL*/

mkdir build && cd build

cd ..
cmake .. -G Ninja \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_LIBRARY_PATH:FILEPATH="${libdir}" \
    -DCMAKE_INCLUDE_PATH:FILEPATH="${includedir}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_PLUGIN_I3S=OFF \
    -DBUILD_PLUGIN_NITF=OFF \
    -DBUILD_PLUGIN_TILEDB=OFF \
    -DBUILD_PLUGIN_ICEBRIDGE=OFF \
    -DBUILD_PLUGIN_HDF=OFF \
    -DBUILD_PLUGIN_PGPOINTCLOUD=OFF \
    -DBUILD_PLUGIN_E57=OFF \
    -DBUILD_PGPOINTCLOUD_TESTS=OFF \
    -DBUILD_PGPOINTCLOUD_TESTS=OFF \
    -DWITH_ZSTD=ON \
    -DWITH_ZLIB=ON \
    -DWITH_TESTS=OFF

ninja -j${nproc}
ninja install
"""

platforms = expand_cxxstring_abis(supported_platforms())

# The products that we will ensure are always built
products = [
    LibraryProduct("libpdal_util", :libpdal_util),
    LibraryProduct(["libpdal_base", "libpdalcpp"], :libpdal_base),
    LibraryProduct("libpdal_plugin_kernel_fauxplugin", :libpdal_plugin_kernel_fauxplugin),
    ExecutableProduct("pdal", :pdal),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="GDAL_jll", uuid="a7073274-a066-55f0-b90d-d619367d196c"))
    Dependency(PackageSpec(name="libgeotiff_jll", uuid="06c338fa-64ff-565b-ac2f-249532af990e"))
    Dependency(PackageSpec(name="LAZperf_jll", uuid="498468b5-6726-5392-b148-b36d48e22663"))
]

# Build the tarballs, and possibly a `build.jl` as well.
# PDAL GitHub CI scripts currently run on GCC 7.5, so we'll match them in major version at least
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version = v"7", julia_compat="1.6")
