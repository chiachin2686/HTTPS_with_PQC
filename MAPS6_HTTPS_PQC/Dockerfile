# Multi-stage build: First the full builder image:

# define the Curl version to be baked in
ARG CURL_VERSION=7.73.0

# Default location where all binaries wind up:
ARG INSTALLDIR=/opt/oqssa

# liboqs build type variant; maximum portability of image:
ARG LIBOQS_BUILD_DEFINES="-DOQS_DIST_BUILD=ON"

# openssl build defines (https://github.com/open-quantum-safe/openssl#build-options)
ARG OPENSSL_BUILD_DEFINES="-DOQS_DEFAULT_GROUPS=kyber512:ntru_hps2048509:ntrulpr653"

# Default root CA signature algorithm; can be set to any listed at https://github.com/open-quantum-safe/openssl#authentication
ARG SIG_ALG="dilithium2"

# Define the degree of parallelism when building the image; leave the number away only if you know what you are doing
ARG MAKE_DEFINES="-j 2"

# define IP addresses or Domain Name
ARG SIP=localhost
ARG CIP=localhost

#FROM alpine:3.11 AS intermediate
#FROM ubuntu:20.04 AS intermediate
FROM debian:bullseye AS intermediate
# Take in all global args
ARG CURL_VERSION
ARG INSTALLDIR
ARG LIBOQS_BUILD_DEFINES
ARG OPENSSL_BUILD_DEFINES
ARG MAKE_DEFINES

LABEL version="2"

# Set timezone
ENV TZ=Asia/Taipei
ENV DEBIAN_FRONTEND=noninteractive

# Copy CA certificate and CA key from the local storage to a destination in the Docker image
WORKDIR /
RUN mkdir certs
ADD certs/* /certs/
RUN chmod 777 /certs/* && sed -i 's/\r//' /certs/* && mkdir -p ${INSTALLDIR}/certs && cp -r /certs/* ${INSTALLDIR}/certs/

# Get all software packages required for builing all components:
RUN apt-get update && apt-get install -y build-essential \
            libtool automake autoconf cmake ninja-build gcc \
            make \
            openssl libssl-dev \
            git docker wget

# get all sources
WORKDIR /opt
RUN git clone --depth 1 --branch main https://github.com/open-quantum-safe/liboqs && \
    git clone --depth 1 --branch OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl ossl-src && \
    wget https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz && tar -zxvf curl-${CURL_VERSION}.tar.gz;

# build liboqs shared and static
WORKDIR /opt/liboqs
RUN mkdir build && cd build && cmake -G"Ninja" .. ${LIBOQS_BUILD_DEFINES} -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=/opt/ossl-src/oqs && ninja install
RUN mkdir build-static && cd build-static && cmake -G"Ninja" .. ${LIBOQS_BUILD_DEFINES} -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=/opt/ossl-src/oqs && ninja install

# build OQS-OpenSSL
WORKDIR /opt/ossl-src
# curl looks for shared libraries
# at ./configure time
RUN LDFLAGS="-Wl,-rpath -Wl,${INSTALLDIR}/lib" ./config shared ${OPENSSL_BUILD_DEFINES} --prefix=${INSTALLDIR} && \
    make ${MAKE_DEFINES} && make install;

# set path to use 'new' openssl & curl. Dyn libs have been properly linked in to match
ENV PATH="${INSTALLDIR}/bin:${PATH}"

# generate certificates for openssl s_server, which is what we will test curl against
ENV OPENSSL=${INSTALLDIR}/bin/openssl
ENV OPENSSL_CNF=${INSTALLDIR}/ssl/openssl.cnf

# WORKDIR ${INSTALLDIR}/bin
# # generate CA key and cert
# RUN set -x; \
#     ${OPENSSL} req -x509 -new -newkey ${SIG_ALG} -keyout CA.key -out CA.crt -nodes -subj "/CN=oqstest CA" -days 365 -config ${OPENSSL_CNF}

# build curl - injecting OQS CA generated above into root store
WORKDIR /opt/curl-${CURL_VERSION}

# Download and integrate LetsEncrypt Root CA to CA bundle
# RUN wget https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt && cat ${INSTALLDIR}/bin/CA.crt >> letsencryptauthorityx3.pem.txt 

# For curl debugging enable it by adding the line below to the configure command:
#                    --enable-debug \

RUN env CPPFLAGS="-I/opt/ossl-src/oqs/include" \
        LDFLAGS=-Wl,-R${INSTALLDIR}/lib  \
        ./configure --prefix=${INSTALLDIR} \
                    --with-ca-bundle=${INSTALLDIR}/oqs-bundle.pem \
                    --with-ssl=${INSTALLDIR} && \
    make ${MAKE_DEFINES} && make install && mv /certs/CA.crt ${INSTALLDIR}/oqs-bundle.pem;

# Download current test.openquantumsafe.org test CA cert
# WORKDIR ${INSTALLDIR}
# RUN wget https://test.openquantumsafe.org/CA.crt && mv CA.crt oqs-testca.pem


## second stage: Only create minimal image without build tooling and intermediate build results generated above:
#FROM alpine:3.11 AS dev
#FROM ubuntu:20.04 AS dev
FROM debian:bullseye AS dev
# Take in all global args
ARG INSTALLDIR
ARG SIG_ALG
ENV SIG_ALG=${SIG_ALG}
ARG SIP
ENV SIP=${SIP}
ARG CIP
ENV CIP=${CIP}

## ------ Original Setting ------
RUN apt-get update && apt-get install -y \
    iputils-ping \
    python3-pip \
    python3-rpi.gpio \
    libtiff5-dev \ 
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libfreetype6-dev \ 
    liblcms2-dev \ 
    libwebp-dev \
    python3-setuptools  
#--no-install-recommends

RUN pip3 install --no-binary Pillow requests
RUN pip3 install Adafruit_SSD1306 pyserial
RUN pip3 install Pillow

# Only retain the ${INSTALLDIR} contents in the final image
COPY --from=intermediate ${INSTALLDIR} ${INSTALLDIR}

# set path to use 'new' openssl & curl. Dyn libs have been properly linked in to match
ENV PATH="${INSTALLDIR}/bin:${PATH}"

ENV OPENSSL=${INSTALLDIR}/bin/openssl
ENV OPENSSL_CNF=${INSTALLDIR}/ssl/openssl.cnf

RUN mkdir /home/MAPS6_MVP
RUN mkdir /mnt/SD
RUN mkdir /mnt/USB

COPY . /home/MAPS6_MVP/
COPY NotoSans-Medium.ttf /home/

WORKDIR /home/MAPS6_MVP

CMD python3 PI_test.py

STOPSIGNAL SIGTERM
