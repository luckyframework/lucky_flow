FROM crystallang/crystal:latest
WORKDIR /data
EXPOSE 3002

RUN apt-get update && \
  apt-get install -y chromium-browser firefox && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /data
