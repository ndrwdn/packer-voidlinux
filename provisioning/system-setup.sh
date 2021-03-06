#!/usr/bin/env bash

set -ex

chown root:root /
chmod 755 /
chmod 755 /var
chsh -s /bin/bash root

mv /set-hostname /usr/sbin/set-hostname
chmod u+x /usr/sbin/set-hostname
/usr/sbin/set-hostname void-dev

blkid | grep void-root | sed -e 's/.*UUID="\([^"]*\)".*/UUID=\1\t\/\text4\trw,noatime,nodiratime,discard\t0\t1/' >> /etc/fstab
blkid | grep void-swap | sed -e 's/.*UUID="\([^"]*\)".*/UUID=\1\tswap\tswap\trw,noatime,nodiratime,discard\t0\t0/' >> /etc/fstab

grub-install /dev/sda
grub-mkconfig > /boot/grub/grub.cfg


echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

ln -s /etc/sv/{dhcpcd,sshd,salt-minion,socklog-unix,nanoklogd} /etc/runit/runsvdir/default/

groupadd vagrant
useradd --password $(openssl passwd -crypt 'vagrant') --create-home --gid vagrant --groups vagrant,users,wheel,socklog -s /usr/bin/zsh vagrant
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
chmod 0440 /etc/sudoers.d/10_vagrant
install --directory --owner=vagrant --group=vagrant --mode=0700 /home/vagrant/.ssh
curl --output /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys

cat << SETUP_VAGRANT_USER_EOF > setup.sh
#!/usr/bin/env bash

set -ex

cd /home/vagrant

ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:ndrwdn/dotfiles.git
./dotfiles/makesymlinks.sh

vim -T dumb -E -c 'PlugInstall | quitall' >/dev/null
emacs --batch --eval "(setq network-security-level 'low)" --script ~/.emacs.d/init.el >/dev/null 2>&1

echo export PAGER=less >> .zshrc.local
SETUP_VAGRANT_USER_EOF
chown -R vagrant:vagrant ${SSH_AUTH_SOCK_DIR}
chown vagrant:vagrant setup.sh
sudo -u vagrant sh setup.sh
rm -rf setup.sh
mkdir -p /root/.config/htop
cp /home/vagrant/.config/htop/htoprc /root/.config/htop/htoprc
chown -R root:root ${SSH_AUTH_SOCK_DIR}
