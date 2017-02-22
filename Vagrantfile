# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'voidlinux-dev-test'
  config.vm.box_url = './voidlinux-dev-virtualbox-0.6.box'

  config.vm.synced_folder 'provisioning/salt/roots/', '/srv/salt'

  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = 'provisioning/salt/minion'
    salt.run_highstate = true
    salt.bootstrap_script = '../../../oss/salt-bootstrap/bootstrap-salt.sh'
  end
end
