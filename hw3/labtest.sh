#!/bin/bash

# input
rm -f a.out down_temp* output.txt wget.log

TIMEOUT="timeout 10"
if [[ $OSTYPE != "linux-gnu" ]]; then
	TIMEOUT=""
fi

src=$1;
port=$2;

H1="HW: 3"
H2="PROF: LEE"

echo $src
echo $port

if [[ "$src" =~ ".cpp" ]];
then
	g++ $src
	($TIMEOUT ./a.out $port  > output.txt & wait 2> /dev/null)  &
elif [[ $src =~ ".c" ]];
then
	gcc $src 
	($TIMEOUT ./a.out $port  > output.txt & wait 2> /dev/null)  &
elif [[ $src =~ ".java" ]];
then
	javac $src
	sleep 1
	cname=$(ls HW2*.class | sed 's/.class//')
	($TIMEOUT java $cname $port  > output.txt & wait 2> /dev/null)  &
elif [[ $src =~ ".py" ]];
then
	($TIMEOUT python3 $src $port  > output.txt & wait 2> /dev/null)  &
else
	echo "not supported" $src
fi

sleep 1

wget -O down_temp_biga -nv --header="$H1" --header="$H2" -t 2 -T 10 http://localhost:$port/biga.html
sleep 0.1
wget -O down_temp_a -nv --header="$H1" --header="$H2" -t 2 -T 10 http://localhost:$port/a.html
sleep 0.1
wget -O down_temp_atxt -nv --header="$H1" --header="$H2" -t 2 -T 10 http://localhost:$port/a.txt
sleep 0.1
wget -O down_temp_btxt -o wget.log -nv --header="$H1" --header="$H2" -t 2 -T 10 http://localhost:$port/b.txt
sleep 0.1
#wget -O down_temp_pal -o log.txt --header="$H1" --header="$H2" -t 2 -T 10 http://localhost:$port/palladio.jpg
wget -O down_temp_pal -nv --header="$H1" --header="$H2" -t 2 -T 10 http://localhost:$port/palladio.jpg

sleep 1

#killall -q a.out python3 java
killall -q a.out python3 java

succcnt=0
diff biga.html down_temp_biga
if [[ $? == 0 ]];
then
	let 'succcnt=succcnt+1'
fi
diff a.html down_temp_a
if [[ $? == 0 ]];
then
	let 'succcnt=succcnt+2'
fi
diff a.txt down_temp_atxt
if [[ $? == 0 ]];
then
	let 'succcnt=succcnt+4'
fi

cmp palladio.jpg down_temp_pal
if [[ $? == 0 ]];
then
	let 'succcnt=succcnt+8'
fi

grep "User-Agent: Wget" output.txt > /dev/null
if [[ $? == 0 ]];
then
	let 'succcnt=succcnt+16'
fi

grep "Host: " output.txt > /dev/null
if [[ $? != 0 ]];
then
	let 'succcnt=succcnt+32'
fi

grep "  Content-Type: text/plain" wget.log > /dev/null
if [[ $? != 0 ]];
then
	let 'succcnt=succcnt+64'
fi


# show the result
echo "Result: "b$(bc <<< "obase=2;$succcnt") $src


rm -f a.out down_temp* output.txt wget.log
