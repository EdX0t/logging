FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get install -y --no-install-recommends \
      apache2 \
      ca-certificates \
      apt-transport-https \
      software-properties-common \
      curl \
      dnsutils \
      rsyslog \
      supervisor \
    && apt -y autoremove  \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/apache2

# supervisor main config file
COPY image/supervisord.conf /etc/supervisor/supervisord.conf

# rsyslog config
COPY image/rsyslog.conf /etc/rsyslog.conf
COPY image/rsyslog-start /usr/local/bin/rsyslog-start

# apache config
COPY image/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY image/apache-start /usr/local/bin/apache-start

WORKDIR "/var/www/html"

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]