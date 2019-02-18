FROM ruby:2.5.3-alpine

ENV BUILD_PACKAGES="build-base git"
ENV DEV_PACKAGES="bzip2-dev libgcrypt-dev libxml2-dev libxslt-dev sqlite-dev zlib-dev tzdata postgresql-dev"

RUN apk add --no-cache --update --upgrade --virtual .railsdeps $BUILD_PACKAGES $DEV_PACKAGES
RUN gem install nokogiri -- --use-system-libraries

RUN cp /usr/share/zoneinfo/GMT0 /etc/localtime
RUN echo "GMT0" >  /etc/timezone

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

ARG RAILS_ENV
ARG POSTGRES_DATABASE_URI
ARG POSTGRES_USERNAME
ARG POSTGRES_PASSWORD

ENV RAILS_ENV=${RAILS_ENV}
ENV POSTGRES_DATABASE_URI=${POSTGRES_DATABASE_URI}
ENV POSTGRES_USERNAME=${POSTGRES_USERNAME}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

RUN echo ${RAILS_ENV}

COPY ./Gemfile ./Gemfile.lock ./

RUN bundle install --without test

COPY . .

RUN bundle exec rake db:setup

ENTRYPOINT ["bundle", "exec", "puma", "-C", "config/puma.rb"]
