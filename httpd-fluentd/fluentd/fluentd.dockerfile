FROM fluent/fluentd:v1.15-debian

USER root
RUN gem install elasticsearch -v '~> 7.9.0' \
    && gem install elasticsearch-api -v '~> 7.9.0' \
    && gem install fluent-plugin-elasticsearch \
    && gem install fluent-plugin-multi-format-parser
