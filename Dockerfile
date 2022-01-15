FROM alpine:3.13 AS build

RUN apk add --update --no-cache gcc make musl-dev unzip wget

WORKDIR /usr/src

ARG CC65_VERSION=2.19

RUN wget https://github.com/cc65/cc65/archive/V${CC65_VERSION}.zip -O cc65-${CC65_VERSION}.zip \
  && unzip cc65-${CC65_VERSION}.zip \
  && cd cc65-${CC65_VERSION} \
  && PREFIX=/opt/cc65 make \
  && PREFIX=/opt/cc65 make install \
  && find /opt/cc65/bin -type f -exec strip {} \;

FROM alpine:3.13

RUN apk add --update --no-cache make

COPY --from=build /opt/cc65 /opt/cc65
ENV PATH /opt/cc65/bin:$PATH
WORKDIR /workdir
