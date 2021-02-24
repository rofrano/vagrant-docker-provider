# vagrant-docker-provider

This repo will build a docker image that can be used as a provider for [Vagrant](https://www.vagrantup.com) as a Linux development environment.

The ready made Docker Hub image can be found here: [rofrano/vagrant-provider:ubuntu](https://hub.docker.com/repository/docker/rofrano/vagrant-provider)

## Why Vagrant with Docker?

This was inspired by Apple's introduction of the M1 chip which is ARM based. That means that solutions which use Vagrant and VirtualBox will not work on Apple M1 because VirtualBox requires an Intel processors. This lead me to find a solution for a virtual development environment that works with ARM and thus Apple M1 computers.

[Docker](https://www.docker.com) has introduced the [Apple M1 Tech Preview](https://docs.docker.com/docker-for-mac/apple-m1/) that runs Docker on Macs that have the Apple M1 chip. By using Docker as a provisioner for Vagrant, we can simulate the same experience as developers using Vagrant with VirtualBox. This is one case where you actually do want a Docker container to behave like a VM.

## Image Contents

This image is based on Ubuntu Focal 20.04 and contains  the packages that are needed for a valid vagrant box. This includes the `vagrant` userid with password-less `sudo` privileges. It also contains as `sshd` server. Normally, it is considered a bad idea to run an `ssh` daemon in a Docker container but in this case, the Docker container is emulating a Virtual Machine (VM) to provide a development environment so it makes perfect sense. ;-)

## Example Vagrantfile

Here is a sample `Vagrantfile` that uses this image:

```ruby
Vagrant.configure("2") do |config|
  config.vm.hostname = "ubuntu"

  config.vm.provider :docker do |docker, override|
    override.vm.box = nil
    docker.image = "rofrano/vagrant-provider:ubuntu"
    docker.remains_running = true
    docker.has_ssh = true
    docker.privileged = true
    docker.create_args = ["-v", "/sys/fs/cgroup:/sys/fs/cgroup:ro"]
  end  
end
```

If you want to test the ARM version on an Intel computer just add `--platform=linux/arm64` to the `docker.create_args` line. This will add the `--platform` flag to the `docker run` command to force the `aarch64` image to be used via `qemu`. 

## Command Line Usage 

To use this provider, add the `--provider` flag to your `vagrant` command:

```sh
vagrant up --provider=docker
```

This will use this the docker image specified in your `Vagrantfile` as the base box.

## Build Multi-Archtecture Image

To build this image you must use `buildx` and build it for multiple architectures so that it can run on both Intel and ARM machines.

If you don't have a builder you must first create one:

```sh
% export DOCKER_BUILDKIT=1
% docker buildx create --use --name=qemu
qemu
% docker buildx inspect --bootstrap
```

Then you can build the multi-platform image like this:

```sh
docker buildx build -t rofrano/vagrant-provider:ubuntu --platform=linux/amd64,linux/arm64 --push .
```

This will use QEMU to build a multi-platform image and push it to docker hub.

## Credits

A huge thanks to [Matthew Warman](http://warman.io) who provided the `Dockerfile` from [mcwarman/vagrant-provider](https://github.com/mcwarman/vagrant-docker-provider) as the bases for my `Dockerfile` using `systemd`. He added all the magic to make it work and I am very greateful for his generosity.
