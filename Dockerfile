FROM ruby:alpine

ENV BUILD_PACKAGES="build-base git"
ENV DEV_PACKAGES="bzip2-dev libgcrypt-dev libxml2-dev libxslt-dev sqlite-dev zlib-dev tzdata"

RUN apk add --no-cache --update --upgrade --virtual .railsdeps $BUILD_PACKAGES $DEV_PACKAGES
RUN gem install nokogiri -- --use-system-libraries

RUN cp /usr/share/zoneinfo/GMT0 /etc/localtime
RUN echo "GMT0" >  /etc/timezone

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install --without test

COPY . .

ENV RAILS_ENV="development"

RUN bundle exec rake swagger:docs
RUN bundle exec rake db:setup

ENTRYPOINT ["rails", "s"]
