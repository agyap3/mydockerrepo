Vagrant.configure("2") do |config|
  config.vm.define "classdoka" do |classdoka|
    classdoka.vm.box = "generic/rocky9"
    classdoka.vm.box_check_update = false
    classdoka.vm.hostname = "dokaclass"
    classdoka.vm.network "private_network", ip: "192.168.10.2"

    classdoka.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "classdoka"
    end

    classdoka.vm.provision "shell", inline: <<-SHELL
      # Update system and install Docker
      sudo dnf check-update
      sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo dnf install -y docker-ce docker-ce-cli containerd.io

      # Start and enable Docker service
      sudo systemctl start docker
      sudo systemctl enable docker

      # Add user 'vagrant' and add to 'docker' group
      sudo usermod -aG docker vagrant

      ## Allow 'student' to use sudo without a password (optional)
      #echo "student ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/student

      # Update /etc/hosts to include the hostname
      echo "192.168.10.2 classdoka.example.com classdoka" | sudo tee -a /etc/hosts
      # Debugging: Check /etc/ssh/sshd_config before change
      sudo grep PasswordAuthentication /etc/ssh/sshd_config

      # Modify sshd_config to allow password authentication
      #sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
       sudo sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config

     # Debugging: Check /etc/ssh/sshd_config after change
     sudo grep PasswordAuthentication /etc/ssh/sshd_config

    # Restart SSH service
      sudo systemctl restart sshd
    SHELL
  end
end
