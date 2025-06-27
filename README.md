# 🐳 Inception - Docker Infrastructure Project

A complete Docker-based LEMP stack infrastructure project featuring WordPress, MariaDB, and Nginx with SSL/TLS encryption, all orchestrated with Docker Compose.

## 🌟 Project Overview

Inception is a system administration project that demonstrates the creation of a complete web infrastructure using Docker containers. The project implements a three-tier architecture with secure communication between services and persistent data storage.

### 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Nginx    │    │  WordPress  │    │   MariaDB   │
│  (Reverse   │◄──►│    (PHP     │◄──►│ (Database)  │
│   Proxy)    │    │   Backend)  │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
      ▲                    ▲                    ▲
      │                    │                    │
   Port 443            Port 9000           Port 3306
```

## ✨ Features

- 🔒 **SSL/TLS Encryption** - Self-signed certificates for HTTPS
- 🐋 **Docker Containerization** - Each service runs in its own container
- 🌐 **Custom Docker Network** - Isolated communication between services
- 💾 **Persistent Storage** - Volume mounting for data persistence
- 🔄 **Health Checks** - Automated service health monitoring
- 🚀 **Auto-restart** - Containers restart automatically on failure
- ⚙️ **Environment Configuration** - Centralized configuration management

## 📦 Services

### 🌐 Nginx (Web Server)
- **Base Image**: Debian Stable
- **Purpose**: Reverse proxy and SSL termination
- **Features**:
  - TLS 1.2/1.3 support
  - FastCGI PHP processing
  - Custom SSL certificate generation
  - Access and error logging

### 📝 WordPress (Content Management)
- **Base Image**: Debian Bullseye
- **Purpose**: PHP-based CMS
- **Features**:
  - PHP 7.4 with FPM
  - WP-CLI integration
  - Database connectivity
  - Custom user creation

### 🗄️ MariaDB (Database)
- **Base Image**: Debian Bullseye
- **Purpose**: MySQL-compatible database
- **Features**:
  - Custom database and user creation
  - Health check monitoring
  - Secure root access
  - Data persistence

## 🚀 Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+
- Make utility

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Codam-Max-Valk/inception.git
   cd inception
   ```

2. **Configure environment variables**
   ```bash
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env with your preferred settings
   ```

3. **Create data directories**
   ```bash
   sudo mkdir -p /home/mvalk/data/{wordpress,mariadb}
   sudo chown -R $USER:$USER /home/mvalk/data/
   ```

4. **Start the infrastructure**
   ```bash
   make up
   ```

5. **Access your WordPress site**
   - Visit: `https://mvalk.42.fr` (or your configured domain)
   - Admin panel: `https://mvalk.42.fr/wp-admin`

## 🛠️ Commands

| Command | Description |
|---------|-------------|
| `make up` | Build and start all services |
| `make down` | Stop and remove containers |
| `make clean` | Stop containers and remove volumes |
| `make fclean` | Complete cleanup including images |
| `make re` | Rebuild everything from scratch |

## 📁 Project Structure

```
inception/
├── Makefile                          # Build automation
├── README.md                         # Project documentation
├── data/                            # Persistent data storage
│   ├── mariadb/                     # Database files
│   └── wordpress/                   # WordPress files
└── srcs/
    ├── .env                         # Environment configuration
    ├── docker-compose.yml           # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile           # MariaDB container definition
        │   ├── conf/my.conf         # Database configuration
        │   └── tools/entrypoint.sh  # Database initialization
        ├── nginx/
        │   ├── Dockerfile           # Nginx container definition
        │   ├── conf/default.conf    # Web server configuration
        │   └── tools/setup_tls.sh   # SSL certificate generation
        └── wordpress/
            ├── Dockerfile           # WordPress container definition
            ├── conf/www.conf        # PHP-FPM configuration
            └── tools/wp-config.sh   # WordPress initialization
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN_NAME` | Your domain name | `mvalk.42.fr` |
| `MYSQL_DATABASE` | WordPress database name | `wordpress` |
| `MYSQL_USER` | Database user | `wordpress` |
| `MYSQL_PASSWORD` | Database user password | `wordpress_password` |
| `MYSQL_ROOT_PASSWORD` | Database root password | `your_root_password` |
| `WP_ADMIN_USER` | WordPress admin username | `bro` |
| `WP_ADMIN_PASSWORD` | WordPress admin password | `bros_password` |
| `WP_ADMIN_EMAIL` | WordPress admin email | `bro@example.com` |

### Custom Configurations

- **Nginx**: SSL/TLS configuration in `srcs/requirements/nginx/conf/default.conf`
- **MariaDB**: Database settings in `srcs/requirements/mariadb/conf/my.conf`
- **WordPress**: PHP-FPM configuration in `srcs/requirements/wordpress/conf/www.conf`

## 🔧 Development

### Building Individual Services

```bash
# Build only Nginx
docker build -t inception-nginx srcs/requirements/nginx/

# Build only WordPress
docker build -t inception-wordpress srcs/requirements/wordpress/

# Build only MariaDB
docker build -t inception-mariadb srcs/requirements/mariadb/
```

### Debugging

```bash
# View logs for all services
docker compose -f srcs/docker-compose.yml logs -f

# View logs for specific service
docker compose -f srcs/docker-compose.yml logs -f nginx

# Execute commands in running containers
docker compose -f srcs/docker-compose.yml exec nginx bash
docker compose -f srcs/docker-compose.yml exec wordpress bash
docker compose -f srcs/docker-compose.yml exec mariadb bash
```

## 🚨 Troubleshooting

### Common Issues

1. **Port 443 already in use**
   ```bash
   sudo lsof -i :443
   # Kill the process using port 443
   ```

2. **Permission denied for data directories**
   ```bash
   sudo chown -R $USER:$USER /home/mvalk/data/
   ```

3. **SSL certificate issues**
   ```bash
   # Regenerate certificates
   make fclean && make up
   ```

4. **Database connection issues**
   ```bash
   # Check MariaDB health
   docker compose -f srcs/docker-compose.yml exec mariadb mariadb-admin ping -u root -p
   ```

## 📚 Learning Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of the 42 School curriculum and is for educational purposes.

## 🏆 Acknowledgments

- **42 School** for the project specification
- **Docker Community** for excellent documentation
- **Open Source Projects** that make this infrastructure possible

---

<div align="center">
  <strong>Built with ❤️ using Docker & Docker Compose</strong>
</div>
