#!/bin/bash

function RunSource {
	src=$1
	host=$2
	port=$3
	infile=$4
	outfile=$5
	if [[ "$src" =~ ".cpp" ]];
	then
		g++ $src
		sleep 0.01
		./a.out $host $port < $infile > $outfile 
	elif [[ $src =~ ".c" ]];
	then
		gcc $src 
		sleep 0.01
		./a.out $host $port < $infile > $outfile 
	elif [[ $src =~ ".java" ]];
	then
		javac $src 
		sleep 0.01
		cname=$(ls *.class | sed 's/.class//')
		java $cname $host $port < $infile > $outfile 
	elif [[ $src =~ ".py" ]];
	then
		python3 $src $host $port < $infile > $outfile 
	else
		echo "not supported" $src
		exit
	fi
	rm -f nc.txt kk.txt
	nc -C $host $port < $infile | grep -v "Date: " > nc.txt
	grep -v "Date: " $outfile > kk.txt
	diff nc.txt kk.txt 
}

# input
rm -f a.out *.class nc.txt kk.txt res.txt
src=$1;

echo $1
echo $1 >> /dev/stderr

succcnt=0

RunSource $src netapp.cs.kookmin.ac.kr 80 cmd1.txt res.txt
if [[ $? == 0 ]];
then
	let "succcnt=succcnt+1"
fi


RunSource $src 203.246.112.141 80 cmd2.txt res.txt
if [[ $? == 0 ]];
then
	let "succcnt=succcnt+2"
fi

RunSource $src netapp.cs.kookmin.ac.kr 80 cmd3.txt res.txt
if [[ $? == 0 ]];
then
	let "succcnt=succcnt+4"
fi


RunSource $src www.google.com 80 cmd4.txt res.txt
if [[ $? == 0 ]];
then
	let "succcnt=succcnt+8"
fi

echo "Result: " $succcnt $src

sleep 0.1


rm -f a.out *.class nc.txt kk.txt res.txt
