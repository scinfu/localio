# How to use
#
# Prerequisites:
# 1. Install docker (https://www.docker.com/get-docker)
# 2. Build image (in the folder where Dockerfile is)
#    docker build -t localio .
#
# How to localize:
# 1. Run localize
#     docker run -it --rm -v /${PWD}:/home localio localize
# 2. Change permissions of the /out file with:
#     sudo chown -R $(whoami) out/
#
# How to remove image (to install new version):
#  docker image rm localio

FROM micalexander/alpine-ruby-2.4.1
RUN apk add --no-cache \
  build-base \
  libxml2-dev \
  libxslt-dev \
  git \
  bash
RUN git clone --depth 1 -b master https://github.com/perix4/localio.git
RUN cd localio \
    && gem build localio.gemspec \
    && gem install ./localio-0.1.7.gem
RUN rm -rf localio
RUN rm -rf /var/cache/apk/*
WORKDIR /home