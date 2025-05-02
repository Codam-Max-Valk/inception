FROM debian:stable

RUN apt-get update -y && \
	apt-get install -y nginx openssl \
	iputils-ping \
	gettext \
	net-tools && \
	rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY tools/setup_tls.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_tls.sh 
EXPOSE 443

ENTRYPOINT [ "/usr/local/bin/setup_tls.sh" ]
# Run nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]