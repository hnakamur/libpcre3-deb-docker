# syntax=docker/dockerfile:1
ARG OS_TYPE=ubuntu
ARG OS_VERSION=26.04
FROM ${OS_TYPE}:${OS_VERSION}

# setup clang
ARG LLVM_MAJOR_VERSION=18
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install debhelper dpkg-dev lsb-release xz-utils gcc cmake ninja-build

ARG SRC_DIR=/src
ARG BUILD_USER=build
RUN useradd -m -d ${SRC_DIR} -s /bin/bash ${BUILD_USER}

USER ${BUILD_USER}
COPY --chown=${BUILD_USER}:${BUILD_USER} ./pcre3/ ${SRC_DIR}/pcre3/
ARG PKG_VERSION
WORKDIR ${SRC_DIR}
RUN tar cf - pcre3 | xz -c > pcre3_${PKG_VERSION}.orig.tar.xz

COPY --chown=build:build ./debian ${SRC_DIR}/pcre3/debian/
WORKDIR ${SRC_DIR}/pcre3
ARG PKG_REL_DISTRIB
RUN sed -i "s/DebRelDistrib/${PKG_REL_DISTRIB}/;s/UNRELEASED/$(lsb_release -cs)/" ${SRC_DIR}/pcre3/debian/changelog
RUN dpkg-buildpackage -us -uc

USER root
