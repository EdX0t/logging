FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt -qq update && apt-get install -yq --no-install-recommends \
      apache2 \
      ca-certificates \
      apt-transport-https \
      software-properties-common \
      curl \
      dnsutils \
      rsyslog \
      supervisor \
      logrotate \
    && curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh \
    && apt -y autoremove  \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/apache2

# supervisor config files
COPY image/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY image/supervisor/rsyslogd-supervisord.conf /etc/supervisor/conf.d/01-rsyslogd-supervisord.conf
COPY image/supervisor/apache-supervisord.conf /etc/supervisor/conf.d/02-apache-supervisord.conf
COPY image/supervisor/fluentbit-supervisord.conf /etc/supervisor/conf.d/03-fluentbit-supervisord.conf

# rsyslog config
COPY image/rsyslog/rsyslog-start /usr/local/bin/rsyslog-start

# apache config
COPY image/apache/apache2.conf /etc/apache2/apache2.conf
COPY image/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY image/apache/apache-start /usr/local/bin/apache-start

# fluentbit configs
COPY image/fluent-bit /etc/fluent-bit

WORKDIR "/var/www/html"

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]