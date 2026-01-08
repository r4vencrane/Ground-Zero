#!/bin/sh

echo "%{F#8dff33}󰈀 %{F#8dff33}$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{print $2}')%{u-}"
