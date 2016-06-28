#!/bin/bash

if [ ${1} ]
then

	i=1;
	while [ "${i}" -le 400000 ]
	do
		echo ${i}
		cat ${1} >> ${2}
		i=`expr ${i} + 1`
	done

else
	echo "	Use ${0} <Arquivo in> <Arquivo out>"
fi
