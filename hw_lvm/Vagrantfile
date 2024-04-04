# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :mdadm => {
        :box_name => "generic/ubuntu2204",
        :vm_name => "mdadm",
        :disks => {
          :sata1 => {
          :dfile => './sata1.vdi',
          :size => 250,
          :port => 1
          },
          :sata2 => {
          :dfile => './sata2.vdi',
          :size => 250,
          :port => 2
          },
          :sata3 => {
          :dfile => './sata3.vdi',
          :size => 250,
          :port => 3
          },
          :sata4 => {
          :dfile => './sata4.vdi',
          :size => 250,
          :port => 4
          },
          :sata5 => {
          :dfile => './sata5.vdi',
          :size => 250,
          :port => 5
          }
    }
  }
}
Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxconfig[:vm_name]
      box.vm.boot_timeout = 450
      box.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
        needsController = false
        boxconfig[:disks].each do |dname, dconf|
          unless File.exist?(dconf[:dfile])
            v.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
            needsController = true
          end
        end
        if needsController == true
          boxconfig[:disks].each do |dname, dconf|
            v.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
          end
        end
      end
      if boxconfig.key?(:public)
        box.vm.network "public_network", boxconfig[:public]
      end
      box.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
        sudo sed -i 's/\#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        systemctl restart sshd
      SHELL
    end
  end
end 
