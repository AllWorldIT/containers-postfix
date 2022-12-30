FROM registry.gitlab.iitsp.com/allworldit/docker/alpine:latest

ARG VERSION_INFO=
LABEL maintainer="Nigel Kukard <nkukard@lbsd.net>"

RUN set -ex; \
	true "Postfix"; \
	apk add --no-cache postfix; \
	true "Versioning"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*


# Postfix
COPY etc/supervisor/conf.d/postfix.conf.disabled /etc/supervisor/conf.d/postfix.conf.disabled
COPY init.d/50-postfix.sh /docker-entrypoint-init.d/50-postfix.sh
COPY pre-init-tests.d/50-postfix.sh /docker-entrypoint-pre-init-tests.d/50-postfix.sh
COPY healthcheck.d/50-postfix.sh /docker-healthcheck.d/50-postfix.sh
RUN set -ex; \
		chown root:root \
			/etc/supervisor/conf.d/postfix.conf.disabled \
			/docker-entrypoint-init.d/50-postfix.sh \
			/docker-entrypoint-pre-init-tests.d/50-postfix.sh \
			/docker-healthcheck.d/50-postfix.sh; \
		chmod 0644 \
			/etc/supervisor/conf.d/postfix.conf.disabled; \
		chmod 0755 \
			/docker-entrypoint-init.d/50-postfix.sh \
			/docker-healthcheck.d/50-postfix.sh

EXPOSE 25

