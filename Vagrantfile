Vagrant.configure("2") do |config|

    config.vm.box = "hashicorp/bionic64"
    config.vm.synced_folder "./.", "/home/vagrant/code"

    config.vm.provision :shell, :path => "./vagrant_provision/install_git.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/install_docker.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/install_moodle_compose.sh", privileged: false

    config.vm.network "private_network", type: "dhcp"
end