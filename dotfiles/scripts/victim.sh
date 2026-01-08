#!/bin/bash

ip_address=$(/bin/cat /home/venomcrane/.config/bin/target | awk '{print $1}')
machine_name=$(/bin/cat /home/venomcrane/.config/bin/target | awk '{print $2}')

if [ $ip_address ] && [ $machine_name ]; then
    echo "%{F#8dff33}󰓾 %{F#8dff33}$ip_address%{u-} - $machine_name"
else
    echo "%{F#8dff33}󰓾 %{u-}%{F#8dff33} No target"
fi
