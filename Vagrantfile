Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/jammy64"
    config.vm.synced_folder "./.", "/home/vagrant/code"

    config.vm.provision :shell, :path => "./vagrant_provision/install_git.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/install_docker.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/compose-generator.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/install_moodle_compose.sh", privileged: false

end