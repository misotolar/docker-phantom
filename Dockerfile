FROM ubuntu:noble-20250127

LABEL maintainer="michal@sotolar.com"

ENV PHANTOM_VERSION=2.3.2
ARG VERSION=ab835b15fe2840427a813a56b011126d7adc5abe
ARG SHA256=11cbc28f397e6f9e43d5d29b00c0e79f50a3a43977f9d69c19cb6f9366d07325
ADD https://github.com/connervieira/Phantom/archive/$VERSION.tar.gz /tmp/phantom.tar.gz

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/phantom

RUN set -ex; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        clinfo \
        intel-opencl-icd \
        libcurl3t64-gnutls \
        liblog4cplus-2.0.5t64 \
        libopencv-core406t64 \
        libopencv-features2d406t64 \
        libopencv-flann406t64 \
        libopencv-highgui406t64 \
        libopencv-imgproc406t64 \
        libopencv-objdetect406t64 \
        libopencv-video406t64 \
        libopencv-videoio406t64 \
        libtesseract5 \
    ; \
    apt-get install --no-install-recommends -y \
        build-essential \
        cmake \
        libcurl4-gnutls-dev \
        liblog4cplus-dev \
        libopencv-dev \
        libtesseract-dev \
    ; \
    echo "$SHA256 */tmp/phantom.tar.gz" | sha256sum -c -; \
    tar xf /tmp/phantom.tar.gz --strip-components=1; \
    mkdir -p /build/phantom/src/build; \
    cd /build/phantom/src/build; \
    cmake \
        -DWITH_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
        .. \
    ; \
    make -j $(nproc); \
    make -j $(nproc) install; \
    apt-get remove --purge -y \
        build-essential \
        cmake \
        libcurl4-gnutls-dev \
        liblog4cplus-dev \
        libopencv-dev \
        libtesseract-dev \
    ; \
    apt-get autoremove --purge -y; \
    rm -rf \
        /build/* \
        /usr/src/* \
        /usr/share/doc/* \
        /usr/share/icons/* \
        /usr/share/man/* \
        /var/cache/debconf/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/runtime_data/postprocess/eu.patterns /usr/share/phantom/runtime_data/postprocess/eu.patterns
