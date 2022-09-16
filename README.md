This project you can use to install full configured VMs (in this case MySQL server with phpadmin and 2 git-lab runners: one type - shell, another - docker)

0. download and install virtual box and vagrant

1. download box you need from https://app.vagrantup.com/bento/boxes/ubuntu-18.04 (for example)

2. if vagrant didn't create path .vagrant.d/boxes/ you need to create it in home directory

3. then you should create directory named from downloaded box name in .vagrant.d/boxes/ directory

4. copy or move download box image in .vagrant.d/boxes/downloaded-box-name/

5. create directory for working with vagrant and move in it

6. use command to add download images in vagrant base:
vagrant box add --name ubuntu18.04 /home/sergey/.vagrant.d/boxes/cf00babe-4123-4902-ad3a-c98f80de0e30/cf00babe-4123-4902-ad3a-c98f80de0e30.box

7. you can list added boxes: vagrant box list

8. init environment using name of your box:
vagrant init ubuntu18.04

9. create directories for sharing data with guests systems (in this case www, data-backup)

10. create vagrant-config-vms.yaml and vagrant-config-global.yaml in current_directory/config/vagrant/

11. create scripts for setup and configuring software in current_directory/config/vagrant/provision with corresponding names in vagrant-config-vms.yaml

12. vim Vagrantfile - creare or edit config of Vagrantfile

13. vagrant up

14. vagrant ssh [name of VM]

### Configured VMs on this case ###
- server gitlab runners
- MySQL server with phpMyAdmin;

You can configure your own VMs using this Vagrantfile and vagrant-config-vms.yaml and vagrant-config-global.yaml files
For every VM we have list of variables (obligatory and optional). Description is corresponding yaml files
To create and run VM you should change variable 'setup' in vagrant-config-vms.yaml to 'true' value.
To add VM - add it to array 'VMs' in vagrant-config-vms.yaml`
For every VMs exists optional parameter `VirtualHost`
If it exists, Vagrant in cycle will read data and add automatically virtual host, register it and add value to `/etc/hosts`

## Using VMs ##

- gitlab-runners
  vagrant ssh gitlub-runners

- MySQL server
  - [localhost:8094/phpmyadmin](http://localhost:8094/phpmyadmin)
