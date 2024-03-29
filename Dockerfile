FROM crystallang/crystal:1.5.1
WORKDIR /data
EXPOSE 3002

RUN apt-get update \
  && apt-get install -y \
    libnss3 \
    libgconf-2-4 \
    chromium-browser \
    firefox-geckodriver \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /data
