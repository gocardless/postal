FROM ruby:2.7.1-alpine

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
  rm -rf /usr/local/bundle/cache

COPY . /opt/postal

# Use the development env in order to load development assets, e.g. jquery
RUN RAILS_ENV=development bundle exec rake assets:precompile

RUN addgroup -g 1000 postal && \
	adduser -G postal -u 1000 -D -H -h /opt/postal -s /bin/bash postal && \
	chown -R postal:postal /opt/postal

USER postal
