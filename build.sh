#!/bin/bash
# Copyright (c) 2013 Gordon Williams, Pur3 Ltd. See the file LICENSE for copying permission. 
cd `dirname $0`
mkdir -p html/refimages
rm -f html/*.html
rm -f html/*.js
rm -f html/refimages/*
node bin/build.js

WEBSITE=~/workspace/espruinowebsite

#rm $WEBSITE/reference/*
cp html/*.html $WEBSITE/reference/
cp html/keywords.js $WEBSITE/www/js
cp datasheets/* $WEBSITE/www/datasheets
mkdir -p $WEBSITE/www/refimages
rm $WEBSITE/www/refimages/*
cp html/refimages/* $WEBSITE/www/refimages

MODULEDIR=$WEBSITE/www/modules
mkdir -p $MODULEDIR

#exit 0

# Minify all modules
for module in `ls devices/*.js`; do
  BNAME=`basename $module .js`
  MINJS=${BNAME}.min.js
  # if file doesn't exist, write an empty file so diff works
  if [ ! -f $MODULEDIR/$BNAME.js ]; then
    echo > $MODULEDIR/$BNAME.js
  fi

  if diff devices/$BNAME.js $MODULEDIR/$BNAME.js >/dev/null ; then
    echo "Module $BNAME hasn't changed, leaving"
  else
    echo "Module $BNAME is different or doesn't exist"  

    rm -f $MODULEDIR/$MINJS
    cp devices/$BNAME.js $MODULEDIR/$BNAME.js

    echo min $MODULEDIR/$module to $MINJS  
    node bin/minify.js $MODULEDIR/$BNAME.js $MODULEDIR/$MINJS 
 
     if [[ -s $MODULEDIR/$MINJS ]] ; then 
       echo "$MODULEDIR/$MINJS compile successful"
     else
       rm $MODULEDIR/$BNAME.js
       echo "devices/$BNAME.js compile FAILED."
       exit 1
     fi 
  fi
done
