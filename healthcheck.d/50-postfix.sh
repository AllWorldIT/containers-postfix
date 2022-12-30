#!/bin/sh

# Short circuit if we're not running Postfix
if [ -z "$START_POSTFIX" ]; then
    return 0
fi


POSTFIX_TEST_RESULT_IPV4=$( echo "QUIT" | nc -w 5 127.0.0.1 25 2>&1 )
if ! echo "$POSTFIX_TEST_RESULT_IPV4" | grep -q "2.0.0 Bye"; then
    echo -e "ERROR: Healthcheck failed for Postfix IPv4:\n$POSTFIX_TEST_RESULT_IPV4"
    false
fi
if [ -n "$CI" ]; then
    echo -e "INFO: Healthcheck for Postfix IPv4:\n$POSTFIX_TEST_RESULT_IPV4"
fi


# Return if we don't have IPv6 support
if [ -z "$(ip -6 route show default)" ]; then
    return 0
fi


POSTFIX_TEST_RESULT_IPV6=$( echo "QUIT" | nc -w 5 ::1 25 2>&1 )
if ! echo "$POSTFIX_TEST_RESULT_IPV6" | grep -q "2.0.0 Bye"; then
    echo -e "ERROR: Healthcheck failed for Postfix IPv6:\n$POSTFIX_TEST_RESULT_IPV4"
    false
fi
if [ -n "$CI" ]; then
    echo -e "INFO: Healthcheck for Postfix IPv6:\n$POSTFIX_TEST_RESULT_IPV4"
fi