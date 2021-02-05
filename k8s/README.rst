TACOS for kubernetes
=======================

This is a TACO Shell for openstack.

Build (Optional)
-------------------

There is a TACOS image(jijisa/tacos) in docker hub but if you want to build
it yourself, read docker/README.rst.

Run
-----

Assume the environment variable file for openstack is .adminrc 
in your home directory.
The file /etc/hosts should have the entry for identity service host.

Create a configmap from .adminrc.::

   $ kubectl create configmap tacos \
      --from-env-file=$HOME/.adminrc -n openstack

Apply {deployment,cluster_role_binding,service_account}.yaml manifest.::

   $ kubectl apply -f /path/to/tacos/k8s

Put taco/tacos command in .bash_aliases if OS distro is Debian/Ubuntu.::

   $ vi ~/.bash_aliases
   alias taco="kubectl -n openstack exec -it $(kubectl -n openstack get po \
      -l application=tacos \
      -o jsonpath='{.items[0].metadata.name}') -- taco"
   alias tacos="kubectl -n openstack exec -it $(kubectl -n openstack get po \
      -l application=tacos \
      -o jsonpath='{.items[0].metadata.name}') -- bash"
   $ source ~/.bash_aliases

For centos/RHEL, put the above aliases in .bashrc.
(CentOS/RHEL ignores .bash_aliases.)

commands
----------

Here is the help message of taco command.::

   $ taco -h
   USAGE: /usr/local/bin/taco {-h|-e|-r|-t|-v}
   
    -h --help           Display this help message.
    -d --database       Connect to openstack database.
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

   $ tacos
   root@a5cc02a304c6:/# 

If you want to connect to OpenStack mariadb, run taco with -d option.::

   $ taco -d
   Enter password: 
   Welcome to the MariaDB monitor.  Commands end with ; or \g.
   Your MariaDB connection id is 400723
   Server version: 10.2.31-MariaDB-1:10.2.31+maria~bionic mariadb.org binary distribution
   
   Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
   
   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
   MariaDB [(none)]>


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

