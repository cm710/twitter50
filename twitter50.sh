#!/bin/bash
#The script displays the top ten words in the last 50 tweets after stopwords removal
#The script automatically fetches the stopwords
#Please note that it appears that "rt" is a frequently used word on twitter, so I left it as a valid word.

#set -x

address="http://search.twitter.com/search.json?q=I%20need%20to%20buy&rpp=50&result_type=recent"
stopwordsaddress="http://www.ranks.nl/resources/stopwords.html"

#The address was created in concordance with the documentation on the first link that was provided in the message:
#using the rpp tag it fetches the first 50 tweets and result_type makes sure they are the most recent 
#The address for stopwords was the same as the one provided in the email. I used the first stopwords list on that website

wget -q $address -O result.txt
wget -q $stopwordsaddress

#The two files were downloaded

perl -wne 'print if /<pre>This list is used in our <a target="_blank" href="/../<\/div>/' stopwords.html > temp.1
#The command above fetches the first list of stopwords by searching for the particular set of words at the beginning of the list and ending with the html tag. 
#It was a little tricky to use sed, so after a few tries, I gave perl a shot.


cat temp.1 | sed 's/<br \/>/\n/g' | sed 's/<\/td><td valign="top">//g' | sed 's/<\/td><\/tr><\/tbody><\/table>//g' | sed '1,2d' | sed -e '$d' > stopwords.list
#This command further parses the stopword list as each is surrounded by tags. Therefore it isolates the stopwords
echo a >> stopwords.list
#The word 'a' was not in the list (probably because it had no tag in front of it), so I added it manually.

rm stopwords.html
rm temp.1
#A little bit of cleanup

cat result.txt | sed 's/"text"/\n"text"/g' | sed 's/"text":"//g' | sed 's/".*//g' | tr -d '[:punct:]' | tr 'A-Z' 'a-z' >temp.1
#This command isolates the tweets from the downloaded pages:
#The tweets have "text: " in front of them, so at first, I made sure that they were at the beginning of the line
#afterwards I removed the "text: " tag in front of them
#finally, I have isolated the beginning of each line up until the first quote.
#Then I removed any punctuation signs, and turned each word into lower case.

while read p; do
sed 's/\b'$p'\b//g' < temp.1 > temp.2
cat temp.2 >temp.1
done < stopwords.list
#This iteration checks each line of stopwords.list and deletes its occurences in the result's page 

rm temp.2

cat temp.1 | sed 's/ /\n/g' | sed '/^$/d' | sort | uniq -c | sort -rn | head -n 10 | awk '{print $2}'
#This command places each word on a separate line, sorts the lines and then it makes use of the uniq command to eliminate any duplicate lines and write their number of occurences before each line.
#Afterwards, it sorts them according to their number of occurences, displays the first ten lines and removes the first column.

rm temp.1
rm stopwords.list
rm result.txt
#another cleanup round
