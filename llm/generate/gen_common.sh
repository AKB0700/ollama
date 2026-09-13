# common logic across linux and darwin

init_vars() {
    case "${GOARCH}" in
    "amd64")
        ARCH="x86_64"
        ;;
    "arm64")
        ARCH="arm64"
        ;;
    *)
        ARCH=$(uname -m | sed -e "s/aarch64/arm64/g")
    esac

    LLAMACPP_DIR=../llama.cpp
    CMAKE_DEFS=""
    CMAKE_TARGETS="--target ollama_llama_server"
    if echo "${CGO_CFLAGS}" | grep -- '-g' >/dev/null; then
        CMAKE_DEFS="-DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_VERBOSE_MAKEFILE=on -DLLAMA_GPROF=on -DLLAMA_SERVER_VERBOSE=on ${CMAKE_DEFS}"
    else
        # TODO - add additional optimization flags...
        CMAKE_DEFS="-DCMAKE_BUILD_TYPE=Release -DLLAMA_SERVER_VERBOSE=off ${CMAKE_DEFS}"
    fi
    case $(uname -s) in
    "Darwin")
        LIB_EXT="dylib"
        WHOLE_ARCHIVE="-Wl,-force_load"
        NO_WHOLE_ARCHIVE=""
        GCC_ARCH="-arch ${ARCH}"
        ;;
    "Linux")
        LIB_EXT="so"
        WHOLE_ARCHIVE="-Wl,--whole-archive"
        NO_WHOLE_ARCHIVE="-Wl,--no-whole-archive"

        # Cross compiling not supported on linux - Use docker
        GCC_ARCH=""
        ;;
    *)
        ;;
    esac
    if [ -z "${CMAKE_CUDA_ARCHITECTURES}" ] ; then
        CMAKE_CUDA_ARCHITECTURES="50;52;61;70;75;80"
    fi
}

git_module_setup() {
    if [ -n "${OLLAMA_SKIP_PATCHING}" ]; then
        echo "Skipping submodule initialization"
        return
    fi
    local has_llama_submodule=0
    # Make sure the tree is clean after the directory moves
    if [ -d "${LLAMACPP_DIR}/gguf" ]; then
        echo "Cleaning up old submodule"
        rm -rf ${LLAMACPP_DIR}
    fi
    git submodule init || return 1
    if [ -f ../../.gitmodules ] && git config --file ../../.gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}' | grep -Fxq "llm/llama.cpp"; then
        has_llama_submodule=1
        git submodule update --force ${LLAMACPP_DIR} || return 1
    else
        echo "llama.cpp is vendored, skipping submodule update"
    fi
    if [ ! -d "${LLAMACPP_DIR}" ] || [ ! -f "${LLAMACPP_DIR}/CMakeLists.txt" ]; then
        if [ ${has_llama_submodule} -eq 0 ] && [ -d ../../llama/llama.cpp ]; then
            echo "llama.cpp source is unavailable at ${LLAMACPP_DIR}, skipping LLM runner generation"
            SKIP_RUNNER_GENERATE=1
            return
        fi
        echo "llama.cpp source is unavailable at ${LLAMACPP_DIR}"
        return 1
    fi

}

apply_patches() {
    if [ -n "${SKIP_RUNNER_GENERATE}" ]; then
        return
    fi
    # Wire up our CMakefile
    if ! grep ollama ${LLAMACPP_DIR}/CMakeLists.txt; then
        echo 'add_subdirectory(../ext_server ext_server) # ollama' >>${LLAMACPP_DIR}/CMakeLists.txt
    fi

    if [ -n "$(ls -A ../patches/*.diff)" ]; then
        # apply temporary patches until fix is upstream
        for patch in ../patches/*.diff; do
            for file in $(grep "^+++ " ${patch} | cut -f2 -d' ' | cut -f2- -d/); do
                (cd ${LLAMACPP_DIR}; git checkout ${file})
            done
        done
        for patch in ../patches/*.diff; do
            (cd ${LLAMACPP_DIR} && git apply ${patch})
        done
    fi
}

build() {
    if [ -n "${SKIP_RUNNER_GENERATE}" ]; then
        return
    fi
    cmake -S ${LLAMACPP_DIR} -B ${BUILD_DIR} ${CMAKE_DEFS}
    cmake --build ${BUILD_DIR} ${CMAKE_TARGETS} -j8
}

compress() {
    echo "Compressing payloads to reduce overall binary size..."
    pids=""
    rm -rf ${BUILD_DIR}/bin/*.gz
    for f in ${BUILD_DIR}/bin/* ; do
        gzip -n --best -f ${f} &
        pids+=" $!"
    done
    # check for lib directory
    if [ -d ${BUILD_DIR}/lib ]; then
        for f in ${BUILD_DIR}/lib/* ; do
            gzip -n --best -f ${f} &
            pids+=" $!"
        done
    fi
    echo
    for pid in ${pids}; do
        wait $pid
    done
    echo "Finished compression"
}

# Keep the local tree clean after we're done with the build
cleanup() {
    if [ -n "${SKIP_RUNNER_GENERATE}" ]; then
        return
    fi
    (cd ${LLAMACPP_DIR}/ && git checkout CMakeLists.txt)

    if [ -n "$(ls -A ../patches/*.diff)" ]; then
        for patch in ../patches/*.diff; do
            for file in $(grep "^+++ " ${patch} | cut -f2 -d' ' | cut -f2- -d/); do
                (cd ${LLAMACPP_DIR}; git checkout ${file})
            done
        done
    fi
}
