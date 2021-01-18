FROM    debian:buster-slim
ARG     CINDER_VER
ARG     GLANCE_VER
ARG     KEYSTONE_VER
ARG     NEUTRON_VER
ARG     NOVA_VER
ARG     MASAKARI_VER
ARG     OPENSTACK_VER
ENV     TINI_VERSION v0.19.0
ENV     CIRROS_VERSION 0.5.1
ADD     https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD     http://download.cirros-cloud.net/${CIRROS_VERSION}/cirros-${CIRROS_VERSION}-x86_64-disk.img /cirros.img
COPY    taco taco-test.sh /usr/local/bin/
RUN     apt update && \
        DEBIAN_FRONTEND=noninteractive \
            apt install -y python3 python3-pip curl less watch vim-tiny \
            mariadb-client rabbitmq-server dnsutils iputils-ping && \
        pip3 install --no-cache-dir \
            python-cinderclient==$CINDER_VER \
            python-glanceclient==$GLANCE_VER \
            python-keystoneclient==$KEYSTONE_VER \
            python-neutronclient==$NEUTRON_VER \
            python-novaclient==$NOVA_VER \
            python-masakariclient==$MASAKARI_VER \
            python-openstackclient==$OPENSTACK_VER && \
        chmod +x /tini && \
        echo $CIRROS_VERSION > /CIRROS_VERSION

ENTRYPOINT  ["/tini", "--", "/usr/local/bin/taco"]
CMD         ["--run"]
