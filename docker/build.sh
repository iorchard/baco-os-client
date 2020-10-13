#!/bin/bash
# Specify versions for each clients.
# Refer to https://docs.openstack.org/releasenotes/python-{cinder,...}client
# The default versions are clients of openstack train.
declare -A ver

ver=(
    ["CINDER_VER"]="5.0.0"
    ["GLANCE_VER"]="2.17.0"
    ["KEYSTONE_VER"]="3.21.0"
    ["NEUTRON_VER"]="6.14.0"
    ["NOVA_VER"]="15.1.1"
    ["OPENSTACK_VER"]="4.0.1"
)

# build baco-os-client with build args

docker build \
    $(for k in ${!ver[@]};do echo -n "--build-arg $k=${ver[$k]} ";done) \
    -t baco-os-client .
