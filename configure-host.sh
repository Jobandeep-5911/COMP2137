#!/bin/bash

trap '' SIGTERM SIGHUP SIGINT  # Ignore signals

verbose=false
desiredName=""
desiredIPAddress=""
hostentryName=""
hostentryIPAddress=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -verbose)
            verbose=true
            shift
            ;;
        -name)
            desiredName="$2"
            shift 2
            ;;
        -ip)
            desiredIPAddress="$2"
            shift 2
            ;;
        -hostentry)
            hostentryName="$2"
            hostentryIPAddress="$3"
            shift 3
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Update hostname
update_hostname() {
    if [[ -n "$desiredName" && $(hostname) != "$desiredName" ]]; then
        sudo hostnamectl set-hostname "$desiredName"
        sudo sed -i "s/$(hostname)/$desiredName/" /etc/hosts
        logger "Hostname changed to $desiredName"
        echo "Hostname changed to $desiredName"
    fi
}

# Update IP address
update_ip_address() {
    if [[ -n "$desiredIPAddress" ]]; then
        sudo sed -i "s/$(ip addr show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)/$desiredIPAddress/" /etc/netplan/*.yaml
        sudo netplan apply
        logger "IP address changed to $desiredIPAddress"
        echo "IP address changed to $desiredIPAddress"
    fi
}

# Update /etc/hosts
update_hostentry() {
    if [[ -n "$hostentryName" && -n "$hostentryIPAddress" ]]; then
        if ! grep -q "$hostentryName" /etc/hosts; then
            echo "$hostentryIPAddress $hostentryName" | sudo tee -a /etc/hosts
            logger "Added $hostentryName to /etc/hosts"
            echo "Added $hostentryName to /etc/hosts"
        fi
    fi
}

update_hostname
update_ip_address
update_hostentry
