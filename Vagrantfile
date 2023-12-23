Vagrant.configure("2") do |config|

    config.vm.box = "ubuntu/jammy64"
    config.vm.synced_folder "./.", "/home/vagrant/code"

    config.vm.provision :shell, :path => "./vagrant_provision/install_git.sh"
    config.vm.provision :shell, :path => "./vagrant_provision/install_docker.sh"

    # I use apt for dependencies because is used for the tool is for this image testing only.
    # For the tool I avoid python virtualenv because test script will run upon this VM only.
    config.vm.provision :shell, :inline=>"apt-get install python3-docker"
end