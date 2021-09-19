#! /bin/bash
#╺┳╸┏━┓┏━┓┏┓╻┏━┓╻  ┏━┓╺┳╸┏━╸╻  ╻ ╻
# ┃ ┣┳┛┣━┫┃┗┫┗━┓┃  ┣━┫ ┃ ┣╸ ┃  ┗┳┛
# ╹ ╹┗╸╹ ╹╹ ╹┗━┛┗━╸╹ ╹ ╹ ┗━╸┗━╸ ╹ 
# by Christos Angelopoulos, September 2021
cd ~
mkdir ~/.translately

#zenity file selection, output Directory kai files.txt
FILES=$(zenity --file-selection --filename=Desktop --height=100 width=100 --title="Translately - Select File to Translate"  --window-icon=/usr/share/icons/gnome/16x16/apps/fonts.png)
case $? in 
  0)  
  ;; 
  1)  rm -r ~/.translately;exit
  ;; 
esac

#zenity language selection
TRANSLATE_LANGUAGE=$(zenity --list  --radiolist  --title="Translately"  --text="Translate to which language?" --height=400 --width=200 --window-icon=/usr/share/icons/gnome/16x16/apps/fonts.png --column=Select  --column="Language"  --column="Abbrev"  TRUE Ελληνικά el  False English en  False Francais fr  False Español es  False Deutch de False Italiano it False Українська uk False Dansk da --print-column=3 )
case $? in 
  0)  
  ;; 
  1)  rm -r ~/.translately;exit
  ;; 
esac


echo "$FILES">~/.translately/files.txt
#sed -i 's/\^/\n/g' ~/.translately/files.txt
FILE=$(head -1 ~/.translately/files.txt|tail +1)
DIRECTORY=${FILE%/*}/
NAME=${FILE##*/}

cp "$FILE" ~/.translately/test.txt

# add delimiters to all new lines for futute parsing ()
sed -i 's/$/()/g' ~/.translately/test.txt

#delete all empty lines from original.txt, define TEXT
TEXT=$(cat ~/.translately/test.txt)	
	

# split the FI string without IFS. Delimiter is the charecter"." consisting of the ending of each sentence. when we echo each file (page), we echo a new line. so that we end up with a multi line file, where each line is a sentence
delimiter=". "
conCatString=$TEXT$delimiter
splitMultiChar=()
while [[ $conCatString ]]; do
 splitMultiChar+=( "${conCatString%%"$delimiter"*}" )
 conCatString=${conCatString#*"$delimiter"}
done
for PAGETEXT in "${splitMultiChar[@]}"; do
 
 echo ""$PAGETEXT".">>~/.translately/sentenceoutcome.txt
done

#########
TOTALLINES=$(cat ~/.translately/sentenceoutcome.txt|wc -l)
LINE=1
ERROR=0
(
while [ $LINE -le $TOTALLINES ]
do
 CURRENTLINE=$(head -$LINE ~/.translately/sentenceoutcome.txt|tail +$LINE)
 CURRENTLINETRANSLATED=$(trans -brief :"$TRANSLATE_LANGUAGE" "$CURRENTLINE")
 echo "$CURRENTLINETRANSLATED"|tr -d >>"$DIRECTORY""μετάφραση του ""$NAME"
 sleep 8
 LINE100=$(( $LINE * 100 ))
 PERCENTAGE=$(( $LINE100 / $TOTALLINES))
 ###Estimating Estimated time of arrival
 LINESLEFT=$(( $TOTALLINES - $LINE ))
 SECONDS=$(( $LINESLEFT * 9 ))
 HOURS=$(( SECONDS / 3600 ))
	SECHLEFT=$(( $SECONDS - $((HOURS * 3600 )) ))
	MINUTES=$(( $SECHLEFT / 60 ))
	SECMLEFT=$(( $SECHLEFT - $((MINUTES * 60 )) ))
	HOURSTRING="$HOURS"" hrs"
	MINUTESTRING="$MINUTES"" mins"
	## if hours / minutes left are 0 , they are not mentioned
	if [ $HOURS -eq 0 ]
	then
		HOURSTRING=""
	fi
		if [ $MINUTES -eq 0 ]
	then
		MINUTESTRING=""
	fi
	#echo line starting with #, updated in the zenity progress bar window 
 echo "# Translating line $LINE of $TOTALLINES from "$NAME" ($PERCENTAGE%) ETA : "$HOURSTRING"  "$MINUTESTRING" " $SECMLEFT" secs"
 echo "$PERCENTAGE"
 ###error detection####
 if [ -z "$CURRENTLINETRANSLATED" ]
 then
  ((ERROR++))
 fi
 if [ $ERROR -eq 3 ]
 then
  zenity --info --height=40 --width=400 --title="Translately!" --icon-name=fonts --text="Translating of ""$NAME"" is stopped, Google quota is exceeded!" --window-icon=/usr/share/icons/gnome/16x16/apps/fonts.png --timeout=3
  rm -r ~/.translately;
  rm "$DIRECTORY""μετάφραση του ""$NAME"
  exit
 fi
 ((LINE++))
done
) |
 zenity --progress --height=40 --width=400 \
  --title="Translately!- Translating" \
  --text="Preparing to translate..." \
  --percentage=0 \
  --height=40 \
  --width=500 \
  --window-icon=/usr/share/icons/gnome/16x16/apps/fonts.png \
  --auto-close
    case $? in 
     0)  
     ;; 
     1)  rm -r ~/.translately;exit
     ;; 
    esac
#get rid of new lines created at sentence delimitation/translation, substitute with space   
sed -z -i 's/\n/ /g' "$DIRECTORY""μετάφραση του ""$NAME"  
#substitute old delimiters () with new lines 
sed -i 's/()/\n/g' "$DIRECTORY""μετάφραση του ""$NAME"
rm -r ~/.translately
if [ $ERROR = 0 ]
then
 zenity --info --height=40 --width=400 --title="Translately!" --icon-name=fonts --text="Translating of ""$NAME"" is complete!" --window-icon=/usr/share/icons/gnome/16x16/apps/fonts.png 
fi
