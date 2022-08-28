ARG UBUNTU_TAG=22.04
ARG SNAPRAID_VERSION=12.2
ARG revision=unknown
ARG image_url=https://github.com/peter-murray/snapraid-container

#------------------------------------------------------------------------------------------
FROM ubuntu:${UBUNTU_TAG} as build

ARG SNAPRAID_VERSION

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install wget

ARG BUILD_DIR=/build

RUN mkdir ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

RUN wget https://github.com/amadvance/snapraid/releases/download/v${SNAPRAID_VERSION}/snapraid-${SNAPRAID_VERSION}.tar.gz \
    && tar -xvf snapraid-${SNAPRAID_VERSION}.tar.gz \
    && ls -la

WORKDIR ${BUILD_DIR}/snapraid-${SNAPRAID_VERSION}

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install gcc make

RUN ./configure
RUN make
RUN make check

RUN cp ./snapraid ${BUILD_DIR}/snapraid

#------------------------------------------------------------------------------------------
FROM ubuntu:${UBUNTU_TAG}

ARG image_url
ARG revision
ARG SNAPRAID_VERSION

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install smartmontools

COPY --from=build /build/snapraid /usr/local/bin/snapraid

VOLUME /config

ENTRYPOINT [ "/usr/local/bin/snapraid", "-c", "/config/snapraid.conf" ]

LABEL  org.opencontainers.image.authors="Peter Murray" \
    org.opencontainers.image.url="${image_url}" \
    org.opencontainers.image.documentation="${image_url}/README.md" \
    org.opencontainers.image.source="${image_url}" \
    org.opencontainers.image.version="${SNAPRAID_VERSION}" \
    org.opencontainers.image.revision="${revision}" \
    org.opencontainers.image.vendor="Peter Murray" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="SnapRAID Container" \
    org.opencontainers.image.description="SnapRAID container for runnning SnapRAID under Ubuntu ${UBUNTU_TAG}"
