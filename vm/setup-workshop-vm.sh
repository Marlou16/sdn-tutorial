#!/bin/bash
set -xe

useradd -m -d /home/kpn -s /bin/bash kpn
echo "kpn:kpn" | chpasswd
echo "kpn ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_kpn
chmod 440 /etc/sudoers.d/99_kpn
usermod -aG vboxsf kpn

sudo DEBIAN_FRONTEND=noninteractive sudo add-apt-repository -y ppa:webupd8team/atom
sudo DEBIAN_FRONTEND=noninteractive sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y \
  atom \
  python \
  git \
  software-properties-common \

# install the correct Oracle Java, needed for ONOS
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install oracle-java8-installer oracle-java8-set-default

# install Wireshark and sort out the whole 'sudo-users' pop-up shit.
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common
sudo usermod -a -G wireshark kpn

# retrieving ONOS, ready to use :)
cd /home/kpn/
wget -O onos-1.10.4.tar.gz http://repo1.maven.org/maven2/org/onosproject/onos-releases/onos-1.10.4/onos-1.10.4.tar.gz
tar -zxf onos-1.10.4.tar.gz
sudo rm onos-1.10.4.tar.gz
sudo chown -R kpn:kpn onos-1.10.4
sudo chmod -R 755 onos-1.10.4

# fixing the terminal to miss the NumberFormatException
# should be even better if there is also some context in the .bashrc file ;)
echo "TERM=xterm-color" >> /home/kpn/.bashrc

# Let's install Mininet over the repo but also download the examples :)
sudo apt install -y mininet
cd /home/kpn
git clone https://github.com/mininet/mininet mininet
mv mininet/custom /home/kpn/mininet-topos
mv mininet/examples /home/kpn/mininet-examples
sudo rm -r mininet
sudo chown -R kpn:kpn mininet-topos
sudo chmod -R 755 mininet-topos
sudo chown -R kpn:kpn mininet-examples
sudo chmod -R 755 mininet-examples

# retrieve the extra files for the SDN workshop
cd /home/kpn
mv /home/vagrant/onos-app-ifwd-1.9.0-SNAPSHOT.oar /home/kpn/
mv /home/vagrant/triangle.py /home/kpn/
sudo chown -R kpn:kpn onos-app-ifwd-1.9.0-SNAPSHOT.oar triangle.py
sudo chmod -R 755 onos-app-ifwd-1.9.0-SNAPSHOT.oar triangle.py
mv triangle.py mininet-topos/


# setup script file to easily adapt the favorites bar (must be run by user)
cd /home/kpn
cat > menu_favorites.sh << EOF
#!/bin/bash
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop', 'wireshark.desktop', 'gnome-terminal.desktop']"
EOF

sudo chown kpn:kpn menu_favorites.sh
sudo chmod +x menu_favorites.sh
