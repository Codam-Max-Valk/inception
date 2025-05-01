FROM debian:stable

# Install nginx and openssl
RUN apt-get update -y && \
	apt-get install -y nginx openssl \
	iputils-ping \
	gettext \
	net-tools && \
	rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy and execute SSL setup script
COPY tools/setup_tls.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_tls.sh 

# Create web root directory
RUN mkdir -p /var/www/html

ENTRYPOINT [ "/usr/local/bin/setup_tls.sh" ]

# Start nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]