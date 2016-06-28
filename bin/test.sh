#!/bin/sh

function executaArq() {
	cat ${1} | \
	while read line
	do 
		${line}
	done
}
