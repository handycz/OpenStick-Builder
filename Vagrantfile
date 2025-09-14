# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-13"
  config.vm.provision "shell", name: "build", inline: <<-SHELL
    set -e
    sudo mkdir -p /buildtmp
    sudo mount -t tmpfs buildtmp /buildtmp
    cp -r /build/* .
    sudo ./build.sh
    cp -r files/* /output
  SHELL

  config.vm.synced_folder ".", "/build", create: true
  config.vm.synced_folder "./out", "/output", create: true
end
