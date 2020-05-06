#!/bin/bash

# Sets script to fail if any command fails.
set -e

set_xauth() {
	echo xauth add $DISPLAY . $XAUTH
	touch ~/.Xauthority
	xauth add $DISPLAY . $XAUTH
}

print_usage() {
echo "

Usage:	$0 COMMAND

XAPPS Container

Options:
  help		Print this help
  omnet		Run OMNeT++ IDE
  sumo		Setup SUMO server on port 9999
  valgrind	Install Valgrind for memory access profiling
"
}

case "$1" in
    help)
        print_usage
        ;;
    omnet)
      	set_xauth
      	/root/omnetpp-5.6/bin/omnetpp
        ;;
    sumo)
        /root/veins-veins-5.0/sumo-launchd.py -vv -c sumo
        ;;
    valgrind)
        apt-get install -y valgrind
	;;
    xeyes)
	set_xauth
	xeyes
        ;;
    *)
        exec "$@"
esac
