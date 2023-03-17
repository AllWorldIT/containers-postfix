#!/bin/bash
# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


fdc_test_start postfix "Check mail delivery using IPv4..."
POSTFIX_TEST_RESULT_SMTP_IPV4=$(
	(
		echo "HELO localhost"; sleep 0.5
		echo "MAIL FROM: <root@localhost.localdomain>"; sleep 0.5
		echo "RCPT TO: <root@localhost.localdomain>"; sleep 0.5
		echo "DATA"; sleep 0.5
		echo "PASSED_IPV4"; sleep 0.5
		echo "."; sleep 0.5
		echo "QUIT"
	) | nc -w 5 127.0.0.1 25 2>&1
)
if ! grep -q '250 2\.0\.0 Ok: queued as' <<< "$POSTFIX_TEST_RESULT_SMTP_IPV4"; then
	fdc_test_fail postfix "Postfix did not deliver the mail\n$POSTFIX_TEST_RESULT_SMTP_IPV4"
	false
fi
fdc_test_progress postfix "Verifying mail delivery using IPv4"
for i in {60..0}; do
	if grep -q PASSED_IPV4 /var/spool/mail/root; then
		break
	fi
	fdc_test_progress postfix "Waiting for mail to appear in the root mailbox... ${i}s"
	sleep 1
done
if [ "$i" = 0 ]; then
	fdc_test_fail postfix "Mail was not delivered to the root mailbox!"
	false
fi
fdc_test_pass postfix "Mail delivered to root mailbox using IPv4"


# Return if we don't have IPv6 support
if [ -z "$(ip -6 route show default)" ]; then
	fdc_test_alert nginx-postfix "Not running IPv6 tests due to no IPv6 default route"
	return
fi


fdc_test_start postfix "Check mail delivery using IPv6..."
POSTFIX_TEST_RESULT_SMTP_IPV4=$(
	(
		echo "HELO localhost"; sleep 0.5
		echo "MAIL FROM: <root@localhost.localdomain>"; sleep 0.5
		echo "RCPT TO: <root@localhost.localdomain>"; sleep 0.5
		echo "DATA"; sleep 0.5
		echo "PASSED_IPV6"; sleep 0.5
		echo "."; sleep 0.5
		echo "QUIT"
	) | nc -w 5 ::1 25 2>&1
)
if ! grep -q '250 2\.0\.0 Ok: queued as' <<< "$POSTFIX_TEST_RESULT_SMTP_IPV4"; then
	fdc_test_fail postfix "Postfix did not deliver the mail\n$POSTFIX_TEST_RESULT_SMTP_IPV4"
	false
fi
fdc_test_progress postfix "Verifying mail delivery using IPv6"
for i in {60..0}; do
	if grep -q PASSED_IPV6 /var/spool/mail/root; then
		break
	fi
	fdc_test_progress postfix "Waiting for mail to appear in the root mailbox... ${i}s"
	sleep 1
done
if [ "$i" = 0 ]; then
	fdc_test_fail postfix "Mail was not delivered to the root mailbox!"
	false
fi
fdc_test_pass postfix "Mail delivered to root mailbox using IPv6"
