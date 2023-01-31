# ################## #
# ###### Base ###### #
# ################## #
FROM scratch AS agnos-base
ADD ubuntu-base-20.04.1-base-arm64.tar.gz /

# Build folder
RUN mkdir -p /tmp/agnos

# Stop on error
RUN set -xe

ENV USERNAME=comma
ENV PASSWD=comma
ENV HOST=tici

# Base system setup
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
COPY ./userspace/base_setup.sh /tmp/agnos
RUN /tmp/agnos/base_setup.sh
