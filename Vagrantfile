Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/jammy64"
    config.vm.synced_folder "./.", "/home/vagrant/code"

    config.vm.provision :shell, :path => "./vagrant_provision/install_git.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/install_docker.sh"

    # I use apt for dependencies because the tool is for this images testing only
    config.vm.provision :shell, :inline=>"apt-get install python3-docker"
end