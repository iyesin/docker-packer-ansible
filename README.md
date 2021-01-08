# docker-packer-ansible
Docker image with packer. Ansible and shell provisioners are backed in

Use cases:
- CI/CD pipeline
- OS-agnostic local installation

Usage example:
```shell
docker run --rm -it -v $HOME/.aws:/.aws:ro -v $PWD:/mnt --entrypoint /bin/sh -e AWS_PROFILE=your-profile -e AWS_DEFAULT_REGION=eu-central-1 -e ANSIBLE_SSH_CONTROL_PATH_DIR=/tmp docker-packer-ansible -c 'ln -s /.aws ~/.aws && cd /mnt && packer build image.json'
```
