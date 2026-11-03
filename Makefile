PKG_VERSION=8.39
PKG_REL_PREFIX=15.1hn1
ifdef NO_CACHE
DOCKER_NO_CACHE=--no-cache
endif

LOGUNLIMITED_BUILDER=logunlimited

# Debian 13
deb-debian13: build-debian13
	docker run --rm -v ./libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}debian13:/dist libpcre3-debian13 bash -c \
	"cp /src/libpcre*${PKG_VERSION}* /src/pcre*${PKG_VERSION}* /dist/"
	tar zcf libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}debian13.tar.gz ./libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}debian13/

build-debian13: buildkit-logunlimited
	mkdir -p libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}debian13
	(set -x; \
	git submodule foreach --recursive git remote -v; \
	git submodule status --recursive; \
	docker buildx build --progress plain --builder ${LOGUNLIMITED_BUILDER} --load \
		${DOCKER_NO_CACHE} \
		--build-arg OS_TYPE=debian --build-arg OS_VERSION=13 \
		--build-arg PKG_REL_DISTRIB=debian13 \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		-t libpcre3-debian13 . \
	) 2>&1 | tee libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}debian13/libpcre3_${PKG_VERSION}-${PKG_REL_PREFIX}debian13.build.log
	xz --force libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}debian13/libpcre3_${PKG_VERSION}-${PKG_REL_PREFIX}debian13.build.log

run-debian13:
	docker run --rm -it libpcre3-debian13 bash

buildkit-logunlimited:
	if ! docker buildx inspect logunlimited 2>/dev/null; then \
		docker buildx create --bootstrap --name ${LOGUNLIMITED_BUILDER} \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1; \
	fi

exec:
	docker exec -it $$(docker ps -q) bash

.PHONY: deb-debian13 run-debian13 build-debian13 buildkit-logunlimited exec

# Ubuntu 26.04
deb-ubuntu2604: build-ubuntu2604
	docker run --rm -v ./libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04:/dist libpcre3-ubuntu2604 bash -c \
	"cp /src/libpcre*${PKG_VERSION}* /src/pcre*${PKG_VERSION}* /dist/"
	tar zcf libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04.tar.gz ./libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04/

build-ubuntu2604: buildkit-logunlimited
	mkdir -p libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04
	(set -x; \
	git submodule foreach --recursive git remote -v; \
	git submodule status --recursive; \
	docker buildx build --progress plain --builder ${LOGUNLIMITED_BUILDER} --load \
		${DOCKER_NO_CACHE} \
		--build-arg OS_TYPE=ubuntu --build-arg OS_VERSION=26.04 \
		--build-arg PKG_REL_DISTRIB=ubuntu26.04 \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		-t libpcre3-ubuntu2604 . \
	) 2>&1 | tee libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04/libpcre3_${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04.build.log
	xz --force libpcre3-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04/libpcre3_${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu26.04.build.log

run-ubuntu2604:
	docker run --rm -it libpcre3-ubuntu2604 bash

buildkit-logunlimited:
	if ! docker buildx inspect logunlimited 2>/dev/null; then \
		docker buildx create --bootstrap --name ${LOGUNLIMITED_BUILDER} \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1; \
	fi

exec:
	docker exec -it $$(docker ps -q) bash

.PHONY: deb-ubuntu2604 run-ubuntu2604 build-ubuntu2604 buildkit-logunlimited exec
