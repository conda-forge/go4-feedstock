#!/bin/bash
set -eumx -o pipefail
shopt -s failglob

# rattler-build inlines this file into a subshell in the script it generates, so
# bash parses every line below before any `shopt` here could take effect. Keep
# the file free of extglob patterns such as @(so|dylib).
case "$(uname -s)" in
	Darwin) lib_ext=dylib ;;
	*) lib_ext=so ;;
esac

# Test running an example analysis with Make build
pushd Go4ExampleSimple
make clean
make -j"${CPU_COUNT}"
make # root version 6.36 failed to run analysis after 2nd make
go4analysis -random -number 10000
popd

# Test running another example analysis with CMake build
pushd Go4ExampleUserSource
mkdir build
# shellcheck disable=SC2086
cmake -S ./ -B ./build/ $CMAKE_ARGS
cmake --build build -j"${CPU_COUNT}"
go4analysis -lib "./build/libGo4UserAnalysis.${lib_ext}" -user tafoil50.scf
go4analysis -lib "./build/libGo4UserAnalysis.${lib_ext}" -user befoil50.scf
popd
