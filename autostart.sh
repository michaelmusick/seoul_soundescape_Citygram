#!/bin/bash

echo "Starting up Sonic Space 10, sclang, and Jackd"

cont=true
# Turn the following sleep back on if this is a boot time script
sleep 20

while $cont
	do
    	sudo killall jackd
		sudo killall sclang
		sudo killall scide
		sleep 5



		scide
		echo $?

		sleep 5

		cont=true
    		echo "SuperCollider ended - try again"
done
