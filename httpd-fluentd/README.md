## Log forwarding from apache webserver to Fluentd

This configuration forwards apache logs to a fluentd instance using 2 approaches.
1. Directly configure apache to write to the localfile and to the /usr/bin/logger utility with a remote rsyslog server
configuration. This approach is configured for the docker service `apache01`.
```shell
CustomLog "| /bin/sh -c '/usr/bin/tee -a /var/log/apache2/access.log | /usr/bin/logger -t${ID} --rfc5424=notq -plocal6.notice -n fluentd -P 5140'" combined
ErrorLog "|/bin/sh -c '/usr/bin/tee -a /var/log/apache2/error.log | /usr/bin/logger -t${ID} --rfc5424=notq -plocal6.err -n fluentd -P 5140'"

# logger man: https://man7.org/linux/man-pages/man1/logger.1.html
```
2. Use the rsyslog service with the `imfile` module to track changes to logfiles and forward log entries to a remote rsyslog server.
   This option is configured for the docker service `apache02`.
   The latest rsyslog version v8.16.0 for u16 doesn't support reading env variables, so the configuration needs a hardcoded tag.
   Changed parameters in main rsyslog configuration:
```shell
# send network messages using RFC5424 spec
$ActionForwardDefaultTemplate RSYSLOG_SyslogProtocol23Format
# allow repeated messages (e.g. same request done twice)
$RepeatedMsgReduction off
```
The webserver docker image is using supervisor so we can start one or multiple processes, by bind mounting supervisor configs.

Fluentd is configured to use a single input source of type syslog, with udp on port 5140.
