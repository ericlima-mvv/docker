# Base Image
FROM amazonlinux:2018.03
CMD ["/bin/bash"]

# Maintainer
MAINTAINER ProcessMaker CloudOps <cloudops@processmaker.com>

# Extra
LABEL version="3.4.0"
LABEL description="ProcessMaker 3.4.0 Enterprise Trial Container."


# Declare ARGS and ENV Variable
ARG WORKSPACE
ARG EMAIL
ENV WORKSPACE $WORKSPACE
ENV EMAIL $EMAIL

# Initial steps
RUN yum clean all && yum install epel-release -y && yum update -y
RUN cp /etc/hosts ~/hosts.new && sed -i "/127.0.0.1/c\127.0.0.1 localhost localhost.localdomain `hostname`" ~/hosts.new && cp -f ~/hosts.new /etc/hosts

# Required packages
RUN yum install \
  vim \
  wget \
  nano \
  sendmail \
  nginx \
  mysql56 \
  php71-fpm \
  php71-opcache \
  php71-gd \
  php71-mysqlnd \
  php71-soap \
  php71-mbstring \
  php71-ldap \
  php71-mcrypt \
  -y

# Download ProcessMaker Enterprise Edition, Enterprise Bundle and Plugins
RUN wget -O "/tmp/processmaker-3.4.0.tar.gz" \
      "https://artifacts.processmaker.net/trial/processmaker-3.4.0.tar.gz"
RUN wget -O "/tmp/bundle.tar.gz" \
      "https://artifacts.processmaker.net/trial/bundle-3.4.0.tar.gz"

# Copy configuration files
COPY processmaker-fpm.conf /etc/php-fpm.d
RUN mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
COPY nginx.conf /etc/nginx
COPY processmaker.conf /etc/nginx/conf.d
COPY updateEmail.php /var/tmp

# NGINX Ports
EXPOSE 80

# Docker entrypoint
COPY docker-entrypoint.sh /bin/
RUN chmod a+x /bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
