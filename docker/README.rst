TACOS 
==================

This is a TACO Shell for openstack.

Build (Optional)
-------------------

There is a TACOS image(jijisa/tacos) in docker hub but if you want to build
it yourself, do the following.

Edit client versions in build.sh.::

   ver=(
       ["CINDER_VER"]="5.0.0"
       ["GLANCE_VER"]="2.17.0"
       ["KEYSTONE_VER"]="3.21.0"
       ["NEUTRON_VER"]="6.14.0"
       ["NOVA_VER"]="15.1.1"
       ["MASAKARI_VER"]="5.3.0"
       ["OPENSTACK_VER"]="4.0.1"
   )

The default versions of clients are openstack train release.

Build the image.::

   $ ./build.sh

Run
-----

Assume the environment variable file for openstack is .adminrc 
in your home directory.
The file /etc/hosts should have the entry for identity service host.

Run tacos container.::

   docker run --detach --name tacos \
      --env-file ~/.adminrc \
      --volume /etc/hosts:/etc/hosts \
      jijisa/tacos

Put taco/tacos command in .bash_aliases if OS distro is Debian/Ubuntu.::

   $ vi ~/.bash_aliases
   alias taco="docker exec -it tacos taco"
   alias tacos="docker exec -it tacos bash"
   $ source ~/.bash_aliases

For centos/RHEL, put the above aliases in .bashrc.
(CentOS/RHEL ignores .bash_aliases.)

commands
----------

Here is the help message of taco command.::

   $ taco -h
   USAGE: /usr/local/bin/taco {-h|-e|-r|-t|-v}
   
    -h --help        Display this help message.
    -e --execute        Execute taco command.
    -r --run            Run taco client.
    -t --test           Run taco-test.sh script.
    -v --version        Show openstack client versions.

The -e option is just a wrapper of openstack command.::

   $ taco -e server list -c Name -c Status
   +------+--------+
   | Name | Status |
   +------+--------+
   | test | ACTIVE |
   +------+--------+

If you want to go into taco container shell, run tacos.::

   [clex@taco2-adm-001 ~]$ tacos
   root@a5cc02a304c6:/# 


Test
-----

There is a simple OpenStack test script taco-test.sh.

It creates network, router, vm, volume, etc...

To run a test::

   $ taco --test
   Creating private network...Done
   Creating external network...Done
   Creating router...Done
   Creating image...Done
   ...
   Removing existing test VM...Done
   Creating virtual machine...Done
   Adding external ip to vm...Done
   Removing existing test volume..Done
   Creating volume...Done
   Waiting for test_bfv volume availability...
   Attaching volume to vm...Done
   VM status
   +------------------+------------------------------------------------+
   | Field            | Value                                          |
   +------------------+------------------------------------------------+
   | addresses        | private-net=172.30.1.141, 192.168.22.214       |
   | flavor           | m1.tiny (f86115a7-6f4d-44a5-9bfc-df269086d385) |
   | image            | cirros (990eeda4-c88c-4ab2-8819-66dfc12511cd)  |
   | name             | test                                           |
   | status           | ACTIVE                                         |
   | volumes_attached | id='8c6f79ec-931b-4faf-9368-eee8d5c317b2'      |
   +------------------+------------------------------------------------+

