FROM mppmu/cuda-julia-anaconda:julia06-avx2-cuda91

# User and workdir settings:

USER root
WORKDIR /root


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install MXNet:

COPY provisioning/install-sw-scripts/mxnet-* provisioning/install-sw-scripts/

ENV \
    LD_LIBRARY_PATH="/opt/mxnet/lib:$LD_LIBRARY_PATH" \
    MXNET_HOME="/opt/mxnet"

RUN true \
    && yum install -y \
        openblas-devel \
        opencv-devel \
    && provisioning/install-sw.sh mxnet apache/1.1.0 /opt/mxnet


# Install Boost:

COPY provisioning/install-sw-scripts/boost-* provisioning/install-sw-scripts/

RUN true \
    && yum install -y zlib-devel bzip2-devel xz-devel libicu-devel \
    && provisioning/install-sw.sh boost 1.65.1 /usr


# Install CERN ROOT:

COPY provisioning/install-sw-scripts/root-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/root/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    \
    ROOTSYS="/opt/root"

RUN true \
    && yum install -y \
        libSM-devel \
        libX11-devel libXext-devel libXft-devel libXpm-devel \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.12.06 /opt/root

# Required for ROOT Jupyter kernel:
RUN pip install metakernel  

# Accessing ROOT via Cxx.jl requires RTTI:
ENV JULIA_CXX_RTTI="1"


# Install BAT:

COPY provisioning/install-sw-scripts/bat-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/bat/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/bat/lib:$LD_LIBRARY_PATH" \
    CPATH="/opt/bat/include:$CPATH" \
    PKG_CONFIG_PATH="/opt/bat/lib/pkgconfig:"

RUN true \
    && provisioning/install-sw.sh bat bat/2e39b93 /opt/bat


# Install Atom:

RUN yum install -y \
        lsb-core-noarch libXScrnSaver libXss.so.1 gtk3 libXtst libxkbfile GConf2 alsa-lib \
        levien-inconsolata-fonts dejavu-sans-fonts libsecret \
    && rpm -ihv https://github.com/atom/atom/releases/download/v1.24.1/atom.x86_64.rpm


# Install additional Python packages:

RUN true \
    && conda install -c conda-forge nbpresent pandoc \
    && conda install -c anaconda-nb-extensions nbbrowserpdf \
    && conda install -c damianavila82 rise \
    && pip install jupyterlab \
    && pip install bash_kernel && JUPYTER_DATA_DIR="/opt/anaconda2/share/jupyter" python -m bash_kernel.install


# Install additional packages and clean up:

RUN yum install -y \
        numactl \
        \
        valgrind \
        \
        readline-devel \
        sqlite-devel \
        \
        http://linuxsoft.cern.ch/cern/centos/7/cern/x86_64/Packages/parallel-20150522-1.el7.cern.noarch.rpm \
    && yum clean all


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-4e2fe824"


# Final steps

CMD /bin/bash
