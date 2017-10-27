#!/bin/bash

echo "Starting up S[e]oul Sound[e]scape"

cont=true
# Turn the following sleep back on if this is a boot time script
sleep 20

while $cont
	do
    	sudo killall jackd
		sudo killall sclang
		sudo killall scide
		sleep 5

        # start SC!
		sudo /usr/local/bin/scide
		echo $?

		sleep 5

		cont=true
    		echo "SuperCollider ended - try again"
done
