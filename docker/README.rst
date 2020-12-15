baco-os-client
==================

This is a baco openstack client.

Build
-------

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

The default version of clients is openstack train release.

Build the image.::

   $ ./build.sh


Run
-----

The environment variable file for openstack is .adminrc in your home directory.
The file /etc/hosts should have the entry for identity service host.

Run baco container.::

   docker run --detach --name baco \
      --env-file ~/.adminrc \
      --volume /etc/hosts:/etc/hosts \
      baco-os-client

Put baco/bacos command in .bash_aliases if OS distro is Debian/Ubuntu.::

   $ vi ~/.bash_aliases
   alias baco="docker exec -it baco baco"
   alias bacos="docker exec -it baco bash"
   $ source ~/.bash_aliases

For centos/RHEL, put baco command in .bashrc.
(CentOS/RHEL ignores .bash_aliases.)

commands
----------------

Here is the help message of baco command.::

   $ baco -h
   USAGE: /usr/local/bin/baco {-h|-e|-r|-t|-v}
   
    -h --help        Display this help message.
    -e --execute        Execute baco command.
    -r --run            Run baco client.
    -t --test           Run baco-test.sh script.
    -v --version        Show openstack client versions.

The -e option is just a wrapper of openstack command.::

   $ baco -e server list -c Name -c Status
   +------+--------+
   | Name | Status |
   +------+--------+
   | test | ACTIVE |
   +------+--------+

If you want to go into baco container, run bacos.::

   [clex@taco2-adm-001 ~]$ bacos
   root@a5cc02a304c6:/# 


Test
-----

There is a simple test script baco-test.sh in baco-os-client image.

It creates network, router, vm, volume etc...

To run a test::

   $ baco --test
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

