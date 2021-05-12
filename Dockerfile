FROM nginx:1.18.0 AS base

RUN	apt-get -yq update && \
	apt-get install -yq --no-install-recommends libpcre3 zlib1g && \
	apt-get autoremove -y && \
	apt-get clean -y
	
FROM base AS build

ARG NGINX_RTMP_MODULE_VERSION

WORKDIR	/tmp/workdir

RUN	buildDeps="build-essential \
		   libpcre3-dev \
		   libssl-dev \
		   zlib1g-dev" && \
	apt-get install -yq --no-install-recommends ${buildDeps}
	
RUN	mkdir nginx-rtmp-module && \
	curl -L https://api.github.com/repos/arut/nginx-rtmp-module/tarball/${NGINX_RTMP_MODULE_VERSION} | tar zx -C nginx-rtmp-module --strip=1

RUN	curl -O https://nginx.org/download/nginx-1.18.0.tar.gz && \
	tar zxf nginx-1.18.0.tar.gz && \
	cd nginx-1.18.0 && \
	./configure --with-compat --add-dynamic-module=../nginx-rtmp-module --with-cc-opt="-Wno-error=implicit-fallthrough" && \
	make modules && \
	cp objs/ngx_rtmp_module.so /etc/nginx/modules/
	
FROM base AS release

COPY --from=build /etc/nginx/modules/ngx_rtmp_module.so /etc/nginx/modules/

COPY nginx.conf /etc/nginx/
