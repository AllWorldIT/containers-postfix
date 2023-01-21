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


# Check if we need to enable postfix
if [ -z "$POSTFIX_ROOT_ADDRESS" ] || [ -z "$POSTFIX_MYHOSTNAME" ] || [ -z "$POSTFIX_RELAYHOST" ]; then
	fdc_notice "Disabling Postfix (POSTFIX_ROOT_ADDRESS, POSTFIX_MYHOSTNAME, POSTFIX_RELAYHOST not set)"
	return
fi

fdc_notice "Initializing Postfix settings"

# Check configurable options
if [ -z "$POSTFIX_ABUSE_ADDRESS" ]; then
	POSTFIX_ABUSE_ADDRESS=root
fi
if [ -z "$POSTFIX_ADMIN_ADDRESS" ]; then
	POSTFIX_ADMIN_ADDRESS=root
fi
if [ -z "$POSTFIX_ADMINISTRATOR_ADDRESS" ]; then
	POSTFIX_ADMINISTRATOR_ADDRESS=root
fi
if [ -z "$POSTFIX_WEBMASTER_ADDRESS" ]; then
	POSTFIX_WEBMASTER_ADDRESS=root
fi
if [ -z "$POSTFIX_POSTMASTER_ADDRESS" ]; then
	POSTFIX_POSTMASTER_ADDRESS=root
fi
if [ -z "$POSTFIX_HOSTMASTER_ADDRESS" ]; then
	POSTFIX_HOSTMASTER_ADDRESS=root
fi
if [ -z "$POSTFIX_NOREPLY_ADDRESS" ]; then
	POSTFIX_NOREPLY_ADDRESS=root
fi

# Work out our destinations
if [ -n "$POSTFIX_DESTINATIONS" ]; then
	POSTFIX_DESTINATIONS=", $POSTFIX_DESTINATIONS"
fi

# Setup supervisord for postfix
mv /etc/supervisor/conf.d/postfix.conf.disabled /etc/supervisor/conf.d/postfix.conf

# Remove old inet_protocols option
sed -e '/^inet_protocols =/d' -i /etc/postfix/main.cf

{
	echo "### START DOCKER CONFIG ###"
	echo "inet_protocols = all"
	echo "myhostname = $POSTFIX_MYHOSTNAME"
	echo "smtpd_banner = \$myhostname ESMTP"
	echo "mydestination = \$myhostname, $HOSTNAME$POSTFIX_DESTINATIONS, localhost.localdomain, localhost"
	echo "relayhost = $POSTFIX_RELAYHOST"
	echo "# Output logs to stdout"
	echo "maillog_file = /dev/stdout"
	echo "disable_vrfy_command = yes"
	echo "smtpd_helo_required = yes"
	echo "strict_rfc821_envelopes = yes"

	echo "message_size_limit = 102400000"
	echo "mailbox_size_limit = 0"

	echo "enable_long_queue_ids = yes"

	echo "address_verify_map = lmdb:/var/lib/postfix/verify"
	echo "address_verify_negative_refresh_time = 5m"
	echo "unverified_recipient_reject_code = 550"
	echo "unverified_sender_reject_code = 550"
	echo "unknown_address_reject_code = 550"
	echo "unverified_recipient_reject_reason = Recipient address verification failed"

	echo "smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination"
	echo "smtpd_recipient_restrictions = reject_non_fqdn_recipient, reject_unknown_recipient_domain, permit_mynetworks, warn_if_reject reject_unknown_reverse_client_hostname, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, warn_if_reject reject_unknown_helo_hostname, reject_unauth_destination, reject_unverified_recipient"
	echo "smtpd_sender_restrictions = reject_non_fqdn_sender, reject_unknown_sender_domain"
	echo "smtpd_data_restrictions = reject_multi_recipient_bounce, reject_unauth_pipelining"

	echo "relay_domains = /etc/postfix/relay_domains"
	echo "transport_maps = lmdb:/etc/postfix/transport_maps"
	echo "### END DOCKER CONFIG ###"

} >> /etc/postfix/main.cf

# Master
touch /etc/postfix/master.cf
echo "$POSTFIX_MASTER_CF" | while read -r line; do
	echo "$line" >> /etc/postfix/master.cf
done

# Relay domains
touch /etc/postfix/relay_domains
echo "$POSTFIX_RELAY_DOMAINS" | while read -r domain; do
	echo "$domain" >> /etc/postfix/relay_domains
done

# Transport maps
touch /etc/postfix/transport_maps
echo "$POSTFIX_TRANSPORT_MAPS" | while read -r line; do
	echo "$line" >> /etc/postfix/transport_maps
done
postmap /etc/postfix/transport_maps

# Setup aliases
{
	echo "### START DOCKER CONFIG ###"
	echo "root: $POSTFIX_ROOT_ADDRESS"
	echo "abuse: $POSTFIX_ABUSE_ADDRESS"
	echo "admin: $POSTFIX_ADMIN_ADDRESS"
	echo "administrator: $POSTFIX_ADMINISTRATOR_ADDRESS"
	echo "webmaster: $POSTFIX_WEBMASTER_ADDRESS"
	echo "postmaster: $POSTFIX_POSTMASTER_ADDRESS"
	echo "hostmaster: $POSTFIX_HOSTMASTER_ADDRESS"
	echo "noreply: $POSTFIX_NOREPLY_ADDRESS"
	echo "### END DOCKER CONFIG ###"
} > /etc/postfix/aliases

newaliases

# Make sure the spool directories exist
for i in bounce corrupt defer deferred flush hold incoming maildrop pid private public saved trace; do
	if [ ! -d "/var/spool/postfix/$i" ]; then
		mkdir "/var/spool/postfix/$i"
	fi
done

# Fix spool directory permissions
chown postfix /var/spool/postfix/* /var/lib/postfix
chown root:postfix /var/spool/postfix/pid
chgrp postdrop /var/spool/postfix/maildrop /var/spool/postfix/public
