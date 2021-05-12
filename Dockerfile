FROM nginx:1.18.0 AS base

RUN	apt-get -yq update && \
	apt-get install -yq --no-install-recommends libpcre3 zlib1g && \
	apt-get autoremove -y && \
	apt-get clean -y
	
FROM base AS build

WORKDIR	/tmp/workdir

RUN	buildDeps="build-essential \
		   git \
		   libpcre3-dev \
		   libssl-dev \
		   zlib1g-dev" && \
	apt-get install -yq --no-install-recommends ${buildDeps}
	
RUN	git clone https://github.com/arut/nginx-rtmp-module.git

RUN	curl -O https://nginx.org/download/nginx-1.18.0.tar.gz && \
	tar zxf nginx-1.18.0.tar.gz && \
	cd nginx-1.18.0 && \
	./configure --with-compat --add-dynamic-module=../nginx-rtmp-module && \
	make modules && \
	cp objs/ngx_rtmp_module.so /etc/nginx/modules/
	
FROM base AS release

COPY --from=build /etc/nginx/modules/ngx_rtmp_module.so /etc/nginx/modules/

COPY nginx.conf /etc/nginx/