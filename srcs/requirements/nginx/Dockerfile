FROM debian:latest

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y nginx

# COPY conf/default.conf /etc/nginx/conf.d/default.conf

# COPY tools/setup_tls.sh /tmp/setup_tls.sh
# RUN chmod +x /tmp/setup_tls.sh

# RUN /tmp/setup_tls.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
