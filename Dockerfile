FROM debian:stretch-slim
LABEL maintainer="Phil Hawthorne <me@philhawthorne.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Default versions
ENV INFLUXDB_VERSION=1.7.10
ENV CHRONOGRAF_VERSION=1.7.17
ENV GRAFANA_VERSION=6.5.3

# Grafana database type
ENV GF_DATABASE_TYPE=sqlite3

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

WORKDIR /root

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf \
    # Base dependencies
    && apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y --force-yes install \
        apt-utils \
        ca-certificates \
        curl \
        git \
        htop \
        libfontconfig \
        nano \
        net-tools \
        supervisor \
        wget \
        gnupg \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && mkdir -p /var/log/supervisor \
    && rm -rf .profile \
    # Install InfluxDB
    && wget https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_armhf.deb \
    && dpkg -i influxdb_${INFLUXDB_VERSION}_armhf.deb && rm influxdb_${INFLUXDB_VERSION}_armhf.deb \
    # Install Chronograf
    && wget https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_armhf.deb \
    && dpkg -i chronograf_${CHRONOGRAF_VERSION}_armhf.deb && rm chronograf_${CHRONOGRAF_VERSION}_armhf.deb \
    # Install Grafana
    && wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_armhf.deb \
    && dpkg -i grafana_${GRAFANA_VERSION}_armhf.deb && rm grafana_${GRAFANA_VERSION}_armhf.deb \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Supervisord and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY bash/profile .profile

# Configure InfluxDB
COPY influxdb/influxdb.conf /etc/influxdb/influxdb.conf

# Configure Grafana
COPY grafana/grafana.ini /etc/grafana/grafana.ini

COPY run.sh /run.sh
RUN ["chmod", "+x", "/run.sh"]
CMD ["/run.sh"]
