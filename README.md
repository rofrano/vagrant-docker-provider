# vagrant-docker-image

This repo will build a docker image that can be used as a provider for [Vagrant](https://www.vagrantup.com) as a development environment.

## Why Vagrant with Docker?

This was inspired by Apple's introduction of the M1 chip which is ARM based. That means that solutions which use Vagrant and VirtualBox will not work on Apple M1 because VirtualBox requires an Intel processors. This lead me to find a solution for a virtual development environment that works with ARM and thus Apple M1 computers.

[Docker](https://www.docker.com) has introduced the [Apple M1 Tech Preview](https://docs.docker.com/docker-for-mac/apple-m1/) that runs Docker on Macs that have the Apple M1 chip. By using Docker as a provisioner for Vagrant, we can simulate the same experience as developers using Vagrant with VirtualBox.

## Image Contents

This image is based on Ubuntu:20.04 and mimics the things that are needed for a valid vagrant box. This contains the `vagrant` userid with password-less `sudo` privileges. It also contains as `sshd` server. Normally, it is considered a bad idea to run an `ssh` server in a Docker container but in this case, the Docker container is emulating a Virtual Machine (VM) to provide a development environment so it makes perfect sense. ;-)

## Sample Vagrantfile

Here is a sample `Vagrantfile` that uses thus image:

```ruby
Vagrant.configure("2") do |config|
  config.vm.provider 'docker' do |docker, override|
    override.vm.box = nil
    docker.image = "rofrano/vagrant:ubuntu"
    docker.name = "vagrant-docker"
    docker.remains_running = true
    docker.has_ssh = true
    # docker.create_args = ['--privileged']
  end
end
```

If you want to run Docker inside the container uncomment the `docker.create_args` line like this:

```
    docker.create_args = ['--privileged']
```
This will give the container the privileges needed to run docker inside of it.

