FROM crystallang/crystal:0.29.0

RUN apt-get update \
  && apt-get install -y libnss3 libgconf-2-4 chromium-browser

RUN mkdir /data
WORKDIR /data
ADD . /data
EXPOSE 3002
