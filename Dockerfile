FROM ubuntu:focal

# Install packages need to support vagrant
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get -y --no-install-recommends install sudo curl vim-tiny \
    && apt-get -y --no-install-recommends install openssh-server supervisor man-db rsync \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

# Create the vagrant user
RUN useradd -m -G sudo -s /bin/bash vagrant \
    && echo "vagrant:vagrant" | chpasswd

# Copy confiuguration files
COPY assets /

# Set permissions to vagrant after copy by root
RUN chown -R vagrant:vagrant /home/vagrant ;\
    chmod 600 /home/vagrant/.ssh/authorized_keys

EXPOSE 22

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
