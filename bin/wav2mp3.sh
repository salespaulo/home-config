#!/bin/bash 

if [ -f ~/bin/utils_func.sh ]
then
	. ~/bin/utils_func.sh
else
	echo "ERRO ao carregar: ~/bin/utils_func.sh"
	exit
fi

for i in *.WAV
do
	silentexec -o "mplayer -ao pcm ${i}" "Convertendo ${i}, aguarde..."
	j=`echo ${i} | tr "WAV" "mp3"`
	silentexec -o "lame -h audiodump.wav ${j}" "Convertendo p/ ${j}, aguarde..."
done
