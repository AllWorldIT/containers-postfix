# Introduction

This is the AllWorldIT Postfix image.

# Environment


## START_POSTFIX

If set to "yes", this will start postfix inside the container.

The following also needs to be specified...

* `POSTFIX_ROOT_ADDRESS`: The email address for system email.
* `POSTFIX_MYHOSTNAME`: Hostname for local email delivery.
* `POSTFIX_RELAYHOST`: The contents of relayhost, the server we're relaying mail via.

The follwing aliases are created and forwarded to `$POSTFIX_ROOT_ADDRESS` by default: abuse, admin, administrator, webmaster, postmaster, hostmaster, noreply

To override each one, you can use one of the following optionals...

* `POSTFIX_ROOT_ADDRESS`
* `POSTFIX_ABUSE_ADDRESS`
* `POSTFIX_ADMIN_ADDRESS`
* `POSTFIX_ADMINISTRATOR_ADDRESS`
* `POSTFIX_WEBMASTER_ADDRESS`
* `POSTFIX_POSTMASTER_ADDRESS`
* `POSTFIX_HOSTMASTER_ADDRESS`
* `POSTFIX_NOREPLY_ADDRESS`

To add more destinations to resolve to the above local aliaes one can use `$POSTFIX_DESTINATIONS` and set it to `example.net, example.com` for instance.

In order to add lines to `/etc/postfix/master.cf`, use a multi-line environment variable called `$POSTFIX_MASTER_CF`.

Relay domains can also be setup using a multi-line environment variable called `$POSTFIX_RELAY_DOMAINS`.

Transport maps can be setup by using a multi-line environment variable called `$POSTFIX_TRANSPORT_MAPS`.

