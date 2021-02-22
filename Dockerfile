FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

# From 16.04, Ubuntu uses systemd instead of init - runlevels are kept for compatibility
# Avoid ERROR: invoke-rc.d: could not determine current runlevel
ENV RUNLEVEL 1

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

# Install packages needed for interactive OS
RUN apt-get update \
    && yes | unminimize \
    && apt-get -y install \
       openssh-server \
       supervisor \
       apt-transport-https \
       ca-certificates \
       software-properties-common \
       rsync \
       man-db \
       sudo \
       curl \
       vim-tiny \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create the vagrant user
RUN useradd -m -G sudo -s /bin/bash vagrant \
    && echo "vagrant:vagrant" | chpasswd

# Copy confiuguation files
COPY assets /

# Set permissions to vagrant after copy by root
RUN chown -R vagrant:vagrant /home/vagrant ;\
    chmod 600 /home/vagrant/.ssh/authorized_keys

EXPOSE 22

CMD supervisord -c /etc/supervisord.conf
