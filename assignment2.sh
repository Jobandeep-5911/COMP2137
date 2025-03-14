#!/bin/bash

# Function to configure the network
configure_network() {
    echo "Configuring network..."
    cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
    version: 2
    ethernets:
        eth0:
            addresses:
                - 192.168.16.21/24
EOF
    netplan apply
    echo "Network configuration applied."

    echo "Updating /etc/hosts file..."
    grep -q "192.168.16.21 server1" /etc/hosts || echo "192.168.16.21 server1" >> /etc/hosts
    echo "Updated /etc/hosts file."
}

# Function to install software
install_software() {
    echo "Installing software..."
    apt-get update
    apt-get install -y apache2 squid
    echo "Software installation complete."
}

# Function to create user accounts
create_users() {
    echo "Creating user accounts..."
    useradd -m -s /bin/bash dennis
    usermod -aG sudo dennis
    mkdir -p /home/dennis/.ssh
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" > /home/dennis/.ssh/authorized_keys
    chown -R dennis:dennis /home/dennis/.ssh
    chmod 600 /home/dennis/.ssh/authorized_keys

    for user in aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
        useradd -m -s /bin/bash $user
        mkdir -p /home/$user/.ssh
        # Generate RSA and Ed25519 keys for each user
        ssh-keygen -t rsa -b 2048 -f /home/$user/.ssh/id_rsa -N ""
        ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N ""
        # Add both public keys to authorized_keys
        cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
        cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys
        chown -R $user:$user /home/$user/.ssh
        chmod 600 /home/$user/.ssh/authorized_keys
    done
    echo "User accounts creation complete."
}

# Main script execution
main() {
    configure_network
    install_software
    create_users
    echo "All configurations are complete!"
}

main
