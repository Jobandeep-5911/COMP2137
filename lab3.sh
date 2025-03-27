#!/bin/bash
verbose=false
if [[ "$1" == "-verbose" ]]; then
    verbose=true
    shift
fi

# Transfer and run configure-host.sh on server1
scp configure-host.sh remoteadmin@server1-mgmt:/root
ssh remoteadmin@server1-mgmt -- "/root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4"
if [[ "$verbose" == true ]]; then
    ssh remoteadmin@server1-mgmt -- "/root/configure-host.sh -verbose -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4"
fi

# Transfer and run configure-host.sh on server2
scp configure-host.sh remoteadmin@server2-mgmt:/root
ssh remoteadmin@server2-mgmt -- "/root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3"
if [[ "$verbose" == true ]]; then
    ssh remoteadmin@server2-mgmt -- "/root/configure-host.sh -verbose -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3"
fi

# Update local /etc/hosts
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
