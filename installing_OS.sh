#!/bin/bash

# Declaring variables
osname=""
os=""
vmname=""
cpu=""
ram=""
count=""

while [ 1 ]
do
        # Displaying options for OS selection
        echo -e "\t\t 1) Cirros"
        echo -e "\t\t 2) Rocky8"
        echo -en "\t choose the os for making instance : "
        read osnum

        # Validation user input for OS choice, ensuring it's either 1 or 2
        osnum=$(echo $osnum | gawk '/^[1-2]$/{print $0}')
        if [ -z "$osnum" ]; then
                read -n1 -p "It's wrong. Do it again. Press any key."
                # Restart the loop if input is invalid
                continue
        else
                case $osnum in
                1)
                        os="Cirros";;
                2)
                        os="Rocky8";;
                esac
        fi

        # Prompting user for input
        echo -n "The name of VM : "
        read vmname
        # Validate the VM name using the regular expression
        vmname=$(echo $vmname | gawk '/^[a-z][a-z0-9]{4,14}[a-z]$/')
        if [ -z "$vmname" ]; then
                read -n1 -p "Invalid VM name. Please follow the naming rules."
                continue
        else
                echo "Valid VM name: $vmname"
        fi

        echo -n "CPU count : "
        read cpu
        echo -n "RAM size(MB) : "
        read ram
        echo -n "COUNT : "
        read count

        # Start the libvirtd service
        systemctl start libvirtd

        for ((i=1; i<=count; i++))
        do
                case $os in
                "Cirros")
                        cp /root/cirros-0.6.2-x86_64-disk.img /root/${vmname}${i}.img
                        virt-install --name ${vmname}${i} --vcpus $cpu --ram $ram --network network=default --disk /root/${vmname}${i}.img --import --noautoconsole --graphics none;;
                "Rocky8")
                        cp /root/Rocky-Base.qcow2 /root/${vmname}${i}.qcow2
                        virt-install --name ${vmname}${i} --vcpus $cpu --ram $ram --network network=default --disk /root/${vmname}${i}.qcow2 --import --noautoconsole --graphics none;;
                esac

                # Print a message to indicate that the instance is being created

                echo "being created instance ${vmname}${i}"

                # Wait for the VM to get an IP address
                sleep 3
                # Get the IP address of the VM
                vmip=$(virsh domifaddr ${vmname}${i} | grep ipv4 | gawk '{print $4}' | gawk -F'/' '{print $1}')

                if [ -z "$vmip" ]; then
                        echo -n ". "
                else
                        echo "IP for ${vmname}${i} : $vmip"
                fi
        done
        break
done
