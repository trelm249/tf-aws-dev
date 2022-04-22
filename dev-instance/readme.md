# Readme

This terraform module is to create a development linux instance in your development enclave.
The instance is a RHEL 8 box with 2 vcpus and 4GB ram.
It also has a 30GB drive.
python 3.9, git, docker-ce and docker-compose 2.x are installed.
The ec2-user is a member of the docker group.
Spin the instance up and give it about 10 minutes. You can ssh to the private IP from the VDI once you have pulled the key down.
