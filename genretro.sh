#!/bin/sh
#
# Copyright (c) 2014 Tristan Le Guern <tleguern@bouledef.eu>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 
# Generate the ?d=retro part of a libravatar
#
# For any hash function:
#   - The first char indicates if background and foreground will be inveted;
#   - The second char indicates which color to use as foreground;
#   - The following 15 chars indicate if the pixel is background or foreground;
#   - The fourth line mirror the second;
#   - The fifth line mirror the first;
#   - The background color is fixed.

set -e

readonly PROGNAME="`basename $0`"
readonly VERSION='v1.1'

usage() {
        echo "usage: $PROGNAME email"
}

_md5() {
	if which md5 > /dev/null; then
		md5 -qs $1
	else
		echo -n $1 | md5sum | cut -d' ' -f1
	fi
}

iseven() {
	echo `printf "%d" \'$1` % 2 | bc
}

colorscheme() {
	case "$1" in
		a|b|c|v|w) echo "#2D4FFF";;
		d|e|f|x|y) echo "#FEB42C";;
		g|h|i|z|0) echo "#E279EA";;
		j|k|l|1|2) echo "#1EB3FD";;
		m|n|o|3|4) echo "#E84D41";;
		p|q|r|5|6) echo "#31CB73";;
		s|t|u|7|8|9) echo "#8D45AA";;
	esac
}

iscolored() {
	if [ `iseven $1` -eq 0 ]; then
		echo '#'
	else
		echo ' '
	fi
}

while getopts ":" opt;do
	case $opt in
		:) echo "$PROGNAME: option requires an argument -- $OPTARG";
		   usage; exit 1;;	# NOTREACHED
		?) echo "$PROGNAME: unkown option -- $OPTARG";
		   usage; exit 1;;	# NOTREACHED
		*) usage; exit 1;;	# NOTREACHED
	esac
done
shift $(( $OPTIND -1 ))

if [ -z "$1" ]; then
	echo "$PROGNAME: email address expected"
	usage
	exit 1
else
	input="$1"
	shift
fi

if [ $# -ge 1 ]; then
	echo "$PROGNAME: invalid trailing chars -- $@"
	usage
	exit 1
fi

set -u

hashedtext="`_md5 $input`"

bcolor="#E0E0E0"
fcolor=$( colorscheme `substr $hashedtext 2 1` )
fchar='#'
if [ $( iseven `substr $hashedtext 1 1` ) -eq 1 ]; then
	tmp="$fcolor"
	fcolor="$bcolor"
	bcolor="$tmp"
	fchar=' '
fi

j=3
nline=0
line1=''
line2=''
line3=''
while [ $nline -lt 3 ]; do
	char="`substr $hashedtext $j 1`"
	char="`iscolored $char`"
	case $nline in
		0) line1="$line1$char$char$char$char";;
		1) line2="$line2$char$char$char$char";;
		2) line3="$line3$char$char$char$char";;
	esac
	j=$(( $j + 1 ))

	if [ $(( ($j - 3) % 5 )) -eq 0 ]; then
		nline=$(( $nline + 1 ))
	fi
done

# Draw a border around the avatar using either the backgound or
# foreground color depending on the inverted char
emptyline='"'
for i in `jot 24 0 24 1`; do
	emptyline="$emptyline$fchar"
done
emptyline="$emptyline\","
line1="$fchar$fchar$line1$fchar$fchar"
line2="$fchar$fchar$line2$fchar$fchar"
line3="$fchar$fchar$line3$fchar$fchar"

IFS=''

echo '/* XPM */'
echo 'static char * identicon_24x24[] = {'
echo '/* width height ncolors chars_per_pixel */'
echo '"24 24 2 1",'
echo '/* colors */'
echo '"  c' $bcolor 's background",'
echo '"# c' $fcolor 's foreground",'
echo "/* pixels */"
echo $emptyline
echo $emptyline
echo '"'$line1'",'
echo '"'$line1'",'
echo '"'$line1'",'
echo '"'$line1'",'
echo '"'$line2'",'
echo '"'$line2'",'
echo '"'$line2'",'
echo '"'$line2'",'
echo '"'$line3'",'
echo '"'$line3'",'
echo '"'$line3'",'
echo '"'$line3'",'
echo '"'$line2'",'
echo '"'$line2'",'
echo '"'$line2'",'
echo '"'$line2'",'
echo '"'$line1'",'
echo '"'$line1'",'
echo '"'$line1'",'
echo '"'$line1'",'
echo $emptyline
echo $emptyline
echo '};'

