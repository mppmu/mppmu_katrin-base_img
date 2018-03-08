# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
   test -f "${INSTALL_PREFIX}/lib/libboost_system.so"
}


pkg_install() {
    PACKAGE_VERSION_1=`echo "${PACKAGE_VERSION}" | cut -f 1 -d .`
    PACKAGE_VERSION_2=`echo "${PACKAGE_VERSION}" | cut -f 2 -d .`
    PACKAGE_VERSION_3=`echo "${PACKAGE_VERSION}" | cut -f 3 -d .`
    DOWNLOAD_URL="https://dl.bintray.com/boostorg/release/${PACKAGE_VERSION}/source/boost_${PACKAGE_VERSION_1}_${PACKAGE_VERSION_2}_${PACKAGE_VERSION_3}.tar.bz2"

    mkdir boost
    download "${DOWNLOAD_URL}" \
        | tar --strip-components=1 -x -j -f - -C boost

    cd boost

    ./bootstrap.sh --prefix="${INSTALL_PREFIX}"
    ./b2 -j"$(nproc)" install
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
export PATH LD_LIBRARY_PATH
EOF
}
