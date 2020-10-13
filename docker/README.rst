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
       ["OPENSTACK_VER"]="4.0.1"
   )

The default version of clients is for openstack train release.

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

Put baco command in .bash_aliases if OS distro is Debian/Ubuntu.::

   $ vi ~/.bash_aliases
   alias baco="docker exec -it baco baco"
   $ source ~/.bash_aliases

For centos/RHEL, put baco command in .bashrc
(CentOS/RHEL ignores .bash_aliases.)

