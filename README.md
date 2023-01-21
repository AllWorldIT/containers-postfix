[![pipeline status](https://gitlab.conarx.tech/containers/postfix/badges/main/pipeline.svg)](https://gitlab.conarx.tech/containers/postfix/-/commits/main)

# Container Information

[Container Source](https://gitlab.conarx.tech/containers/postfix) - [GitHub Mirror](https://github.com/AllWorldIT/containers-postfix)

This is the Conarx Containers Postfix image, it provides support for basic email redirection to RFC-standard accounts and relaying
via a configurable host. Configuration can also be added for local mail delivery within the container.



# Mirrors

|  Provider  |  Repository                            |
|------------|----------------------------------------|
| DockerHub  | allworldit/postfix                      |
| Conarx     | registry.conarx.tech/containers/postfix |



# Conarx Containers

All our Docker images are part of our Conarx Containers product line. Images are generally based on Alpine Linux and track the
Alpine Linux major and minor version in the format of `vXX.YY`.

Images built from source track both the Alpine Linux major and minor versions in addition to the main software component being
built in the format of `vXX.YY-AA.BB`, where `AA.BB` is the main software component version.

Our images are built using our Flexible Docker Containers framework which includes the below features...

- Flexible container initialization and startup
- Integrated unit testing
- Advanced multi-service health checks
- Native IPv6 support for all containers
- Debugging options



# Community Support

Please use the project [Issue Tracker](https://gitlab.conarx.tech/containers/postfix/-/issues).



# Commercial Support

Commercial support for all our Docker images is available from [Conarx](https://conarx.tech).

We also provide consulting services to create and maintain Docker images to meet your exact needs.



# Environment Variables

Additional environment variables are available from...
* [Conarx Containers Alpine image](https://gitlab.conarx.tech/containers/alpine).

Postfix is only enabled when the all three of `POSTFIX_ROOT_ADDRESS`, `POSTFIX_MYHOSTNAME`, `POSTFIX_RELAYHOST` appear in the ENV.


## POSTFIX_ROOT_ADDRESS (required)

This is the email address for system email, system mail will be sent to this address including bounce notifications.

The follwing aliases are created and forwarded to `POSTFIX_ROOT_ADDRESS` by default ... `abuse`, `admin`, `administrator`,
`webmaster`, `postmaster`, `hostmaster`, `noreply`.

Each address can be overridden using environment variables in the below table.

| Address        | Environment Variable          |
|----------------|-------------------------------|
| abuse@         | POSTFIX_ABUSE_ADDRESS         |
| admin@         | POSTFIX_ADMIN_ADDRESS         |
| administrator@ | POSTFIX_ADMINISTRATOR_ADDRESS |
| webmaster@     | POSTFIX_WEBMASTER_ADDRESS     |
| postmaster@    | POSTFIX_POSTMASTER_ADDRESS    |
| hostmaster@    | POSTFIX_HOSTMASTER_ADDRESS    |
| noreply@       | POSTFIX_NOREPLY_ADDRESS       |


## POSTFIX_MYHOSTNAME (required)

Hostname for local email delivery.


## POSTFIX_RELAYHOST (required)

This is the hostname or IP mail will be relayed through.


## POSTFIX_DESTINATIONS

Domains treated as `local` and to which the configurations for `POSTFIX_*_ADDRESS` applies. By default `POSTFIX_MYHOSTNAME` is
considered local.

Specifying multiple additional domains can be done in a comma-separated list, eg. `example.net, example.org`.


## POSTFIX_RELAY_DOMAINS

Multi-line option to setup relay domains, these are needed when `POSTFIX_TRANSPORT_MAPS` are used to deliver inbound mail locally.

These can be specified in the following manner...

```yaml
POSTFIX_RELAY_DOMAINS: |
    helpdesk.example.com
    support.example.com
```


## POSTFIX_TRANSPORT_MAPS

Multi-line option to setup transport maps to map inbound mail to certain transports. There should be a corresponding
`POSTFIX_RELAY_DOMAINS` entry for any domain added here.

An example of a setup like this is below...

```yaml
POSTFIX_TRANSPORT_MAPS: |
    reply@helpdesk.example.com                rt:1
    comment@helpdesk.example.com              rt:1
    sales@helpdesk.example.com                rt:3
    sales-comment@helpdesk.example.com        rt:3
    custserv@helpdesk.example.com             rt:4
    custserv-comment@helpdesk.example.com     rt:4
    support@helpdesk.example.com              rt:5
    support-comment@helpdesk.example.com      rt:5
    helpdesk.example.com                      local:
```

With a corresponding transport which would normally be setup by the image...

```yaml
echo 'rt unix - n n - - pipe flags=DORhu user=rt argv=/opt/rt5/bin/rt-mailgate --queue $nexthop --action correspond --url http://localhost/' >> /etc/postfix/master.cf
```


## POSTFIX_MASTER_CF

Additional configuration can be added to `/etc/postfix/master.cf` by using a multi-line environment variable called
`POSTFIX_MASTER_CF`.



# Exposed Ports

Postfix port 25 is exposed.
