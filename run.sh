#!/bin/bash

if [[ -z $1 ]]
then
	echo "Supply a board file as arg 1"
	exit
fi

cat $1 prog.s > life.s
spim -file life.s
