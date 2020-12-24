#!/bin/bash

set -e -o pipefail

get_cirros_image () {
    # Deprecated!!! Not used anymore.
    # tacos image already has the image (/cirros.img)
    local rel_url="http://download.cirros-cloud.net/version/released"
    IMG="/cirros.img"

    echo "Try to get cirros image from the internet..."
    if curl --connect-timeout 3 --silent --output /dev/null -I $rel_url;then
        echo "Yes, I can get cirros image. Download it."
        v=$(curl -s $rel_url)
        curl -sLo $IMG \
            http://download.cirros-cloud.net/${v}/cirros-${v}-x86_64-disk.img
    else
        echo "Fail to get cirros image from the internet."
        read -p 'Type the image path. (/path/to/imgfile): ' IMG
    fi
    # check the image file exists.
    if [ ! -f "$IMG" ]; then
        echo "Cannot find an image. Abort."
        exit 1
    fi

}
ask_public_net_settings () {
    
    while true; do
        read -p 'Type the provider network address (e.g. 192.168.22.0): ' PN
        # check if PN has the right format.
        if grep -P -q  "^\d+\.\d+\.\d+.\d+\/\d" <<<"$PN"; then
            echo "Okay. I got the provider network address: $PN"
            break
        fi
        echo "You typed the wrong subnet address format. Type again."
    done
    
    while true; do
        read -p 'The first IP address to allocate (e.g. 192.168.22.100): ' FIP
        # check if FIP is in PN range.
        if [ "$FIP" =~ "$PN" ];then
            echo "Okay. I got the first address in PN pool: $FIP"
            break;
        fi
        echo "You typed the wrong IP address. Type again."
    done
    
    while true; do
        read -p 'The last IP address to allocate (e.g. 192.168.22.200): ' LIP
        # check if LIP is in PN range.
        if [ "$FIP" =~ "$PN" ];then
            # check if LIP is bigger than FIP
            IFS='.'
            l=($LIP)
            f=($FIP)
            if [ $l[3] -gt $f[3] ]; then
                echo "Okay. I got the last address in PN pool: $LIP"
                break;
            fi
        fi
        echo "You typed the wrong IP address. Type again."
    done
}

echo -n "Creating private network..."
if ! openstack network show private-net >/dev/null 2>&1; then
    openstack network create private-net
    openstack subnet create \
        --network private-net \
        --subnet-range 172.30.1.0/24 \
        --dns-nameserver 8.8.8.8 \
        private-subnet
fi
echo "Done"

echo -n "Creating external network..."
if ! openstack network show public-net >/dev/null 2>&1; then
    ask_public_net_settings
    openstack network create \
        --external \
        --share \
        --provider-network-type flat \
        --provider-physical-network external \
        public-net
    openstack subnet create --network public-net \
        --subnet-range ${PN}/24 \
        --allocation-pool start=${FIP},end=${LIP} \
        --dns-nameserver 8.8.8.8 public-subnet
fi
echo "Done"
echo -n "Creating router..."
if ! openstack router show admin-router >/dev/null 2>&1; then
    openstack router create admin-router
    openstack router add subnet admin-router private-subnet
    openstack router set --external-gateway public-net admin-router
    openstack router show admin-router
fi
echo "Done"

echo -n "Creating image..."
IMG="/cirros.img"
if [ ! -f "$IMG" ]; then
    echo "cirros image(/cirros.img) not found. Abort."
    exit 1
fi

if ! openstack image show cirros >/dev/null 2>&1; then
    openstack image create \
        --disk-format qcow2 \
        --container-format bare \
        --file $IMG \
        --tag $(cat /CIRROS_VERSION) \
        --public \
        cirros
    openstack image show cirros
fi
echo "Done"

echo -n "Adding security group for ssh"
set +e +o pipefail
SEC_GROUPS=$(openstack security group list --project admin | grep default | awk '{print $2}')
for sec_var in $SEC_GROUPS
do
    SEC_RULE=$(openstack security group rule list $SEC_GROUPS | grep 1:65535 | awk '{print $8}')
    if [ "x${SEC_RULE}" != "x1:65535" ]; then
        openstack security group rule create --proto tcp --remote-ip 0.0.0.0/0 --dst-port 1:65535 --ingress  $sec_var
        openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 $sec_var
        openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 --egress $sec_var
    fi
done
echo "Done"

set -e -o pipefail
if openstack server show test >/dev/null 2>&1; then
    echo -n "Removing existing test VM..."
    openstack server delete test
    echo "Done"
fi

if ! openstack flavor show m1.tiny >/dev/null 2>&1; then
    echo -n "Create m1.tiny flavor."
    openstack flavor create --vcpus 1 --ram 1024 --disk 10 m1.tiny
    echo "Done"
fi

IMAGE=$(openstack image show cirros -f value -c id)
FLAVOR=$(openstack flavor show m1.tiny -f value -c id)
NETWORK=$(openstack network show private-net -f value -c id)

echo -n "Creating virtual machine..."
openstack server create \
    --image $IMAGE \
    --flavor $FLAVOR \
    --nic net-id=$NETWORK --wait \
    test >/dev/null
echo "Done"

echo -n "Adding external ip to vm..."
FLOATING_IP=$(openstack floating ip create public-net | grep floating_ip_address | awk '{print $4}')
openstack server add floating ip test $FLOATING_IP
echo "Done"


if openstack volume show test_bfv >/dev/null 2>&1; then
  echo -n "Removing existing test volume.."
  openstack volume delete test_bfv
  echo "Done"
fi

echo -n "Creating volume..."
openstack volume create --size 5 --image $IMAGE test_bfv >/dev/null
echo "Done"
i=0
VOLUME_STATUS=""
set +e +o pipefail
until [ x"${VOLUME_STATUS}" = x"available" ]
do
  echo "Waiting for test_bfv volume availability..."
  sleep 1
  VOLUME_STATUS=$(openstack volume show test_bfv -f value -c status)
  if [ "$i" = "10" ]; then
    echo "Abort: Volume is not available at least 10 seconds so I give up."
    exit 1
  fi
  ((i++))
done

set -e -o pipefail
echo -n "Attaching volume to vm..."
openstack server add volume test test_bfv
echo "Done"

echo "VM status"
openstack server show test -c name -c addresses -c flavor \
    -c status -c image -c volumes_attached
