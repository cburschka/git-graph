#!/bin/bash

URL=$1
shift 1
echo 'strict digraph git {'
echo '#edges'
git log --all --no-merges --first-parent --min-parents=1 --pretty='format:"%p" -> "%h" [style=bold,color=blue];'
git log --all --no-merges --min-parents=1 --pretty='format:"%p" -> "%h";'
git log --all --merges --pretty='format:%h %p'| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,";\n{",$3,$4,"} ->",$1,"[style=dotted];"}'
git log --all --merges --first-parent --pretty='format:%h %p'| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,"[style=bold,color=blue];\n{",$3,$4,"} ->",$1,"[style=dotted];"}'

echo '#refs'
git log --decorate=short --no-walk --remotes --pretty='format: "%h" [label="%h %d",style=filled,color="lightblue"];'
git log --decorate=short --no-walk --tags --pretty='format: "%h" [label="%h %d",style=filled,color="green"];'
git log --decorate=short --no-walk --branches --pretty='format: "%h" [label="%h %d",style=filled,color="yellow"];'
if [ ! -z "$URL" ]
then
  git log --all --pretty='format: "%h" [URL="'$URL'%h"];'
fi
echo '}'
