#!/bin/bash

mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/juwang.42.fr.key \
    -out /etc/nginx/ssl/juwang.42.fr.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=juwang/CN=juwang.42.fr"

