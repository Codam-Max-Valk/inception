FROM debian:stable

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y nginx openssl

COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/fastcgi_params /etc/nginx/fastcgi_params

RUN openssl req -x509 -nodes -days 365 -subj "/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/certs/nginx.key -out /etc/ssl/certs/nginx.crt

# Create directory for WordPress files
RUN mkdir -p /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
