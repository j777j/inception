# srcs/requirements/nginx/Dockerfile
FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

RUN /usr/local/bin/setup.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
