2

clear
pwd

3
cal
cal 7 2006
cal 2003 4
cal feb 2033
date
date '+DATE:%m-%y%nTIME:%H:%M:%S'

4
touch test1 test2 test3
mkdir test 
pwd 
mkdir Documents/Test_Folder
cd Music 

5
cat test 
no such file or directory

cat > test 
This is a test file.
ctrl+d

cat < test 
clear 

cat > random 
This is a random file.

cat < random 
< is optional, its default 

to merge
cat random test > sample
cat sample 

6
touch forest_gump
mv forest_gump the_green_mile

rm the_green_mile

mkdir new 
rm new 
rm -r new 
mkdir test 
rmdir test 

7
touch old 
cp old Music/old_music

links
ln old new 

both are empty
time some text in old 
open new u can see data there as its a link 

soft link 
ln -s old old_soft 

8
touch sample 
permissions owner,group,others 
read 4
write 2
execute 1
6 means read and write 

umask 
0022
first 0 is octal number
concentrate on last 3 digits

when a file is created in linux unix substracts 022 from 666 for the file 
from 777 for the directory 

file = 666 - 022 = 644 (read&write, read, read)
dir  = 777 - 022 = 755 (read-write-execute,read+execute, read+execute)

9
cat > test 
I am feeling hungry.

ls

cd Documents 
ls

ls Documents

to see permissions (long listing)

ls -l 
total 48 is number of blocks occupied, one block is unit of memory 
block=1024 bytes 

- is file 
d is directory 

hidden files 
touch .new 
this creates hidden file 
ctrl+h to view it 

ls -a 

10
change file permissions 

chmod 
touch test 
ls 
ls -l

chmod 777 test 
ls -l 

chmod 444 test
ls -l 

if u have exe permission on directoryu can double click to go into it 

uname 
uname -a 
-a means all info 


11
count lines, words, characters usinc wc 

wc = word count 

cat > jazzy 
This is the first line.
We are on line two now. 
I don't know where this is going to go.
I think I need to sleep for a few hours.
ctrl+d 

cat jazzy 

file *

wc jazzy
4 30 130 jazzy 

wc -l jazzy 
4 jazzy 

wc -w jazzy 
30 jazzy

wc -c jazzy 
130 jazzy


12
sort 
cat > animals
owls 
camels
pigs
dogs
lions
elephants
asses
ctrl+d 

cat animals 

cat > sports
cricket
tennis
ice hockey
soccer
basketball
wrestling 

cat sports 
clear 

sort animals 

sort sports

clear 

sort enter 
enter text
Apcalypse now 
Cast away 
Forrest gump
Raging Bull
Aviator
Saving Private Ryan
ctrl d


13
Cut Through Your files 
cat > players
Name-Sport-Age
Roger-Tennis-30
Rafel Nadal-Tennis-25
Tiger Woods-Golf-37
Michael Phelps-Swimmer-27
Kobe Bryant-Basketball-34

cat players

to see name and age 
cut -d"-" -f 1,3 players 

if u just want to see sport 
cut -d"-" -f 2 players 


14
Convert & Copy Files With 'dd'

cat > test 
This is an ascii text file.
ctrl+d 

to convert the file info into capital letters

cat test
if = input file 
of = output file 

dd if=test of=out conv=ucase

clear 
cat test 
cat out 

to convert from ascii to europian 
dd if=test of=test2 conv=ebcdic

file * (see the filetype)
cat test2 


15
get help, view fancy text & reduce file size 

man command 
q to exit from man command 

banner = to generate fancy text 
banner I am a bad programmer 

banner "bye bye" will take only 10 char 

compress command 

compress -v test 
-v will display % of compression 

cat test 

zcat test.Z (will display proper text)

uncompress test.Z 
ls


16
Hello World 

ss1.sh

#This is my first shell script.
echo "Hello World"


17
Use commands in your scripts 

ss2.sh 
#this is my second script file. 
pwd
ls -l 
banner "The End"


18
Shell variables, grab user input using read 

variables are case sensitive 

my_var is different from MY_VAR 

_var

echo command will enter a new line command at the end of line by default 

ss3.sh 
#this script demonstrates theusage of read command.
echo "Please enter your name"
read my_name 
echo "Hello $my_name, It's a fine day, isn't itt?"
