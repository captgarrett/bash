#!/bin/bash


MONIT="$(service monit status | grep 'stop')"

if [ "$(service monit status | grep 'stop')" = "monit is not running" ]; then
    echo "monit was off, starting it" >> /var/log/autorestarter_logging.log && service monit start
fi

if [ "$(service svar-fds-extraction status | grep 'stop')" = "svar-fds-extraction stop/waiting" ]; then
    echo "svar-fds-extraction was off, starting it" >> /var/log/autorestarter_logging.log && service svar-fds-extraction start
fi

if [ "$(service feature_listener status | grep 'stop')" = "feature_listener stop/waiting" ]; then
    echo "feature_listener was off, starting it" >> /var/log/autorestarter_logging.log && service feature_listener start
fi
