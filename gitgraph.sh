#!/bin/bash

URL=$1
shift 1
read -d '' header <<- EOF
strict digraph git {
  #legend
EOF
read -d '' header2 <<- EOF
  subgraph cluster_01 {
    node [shape=plaintext]
    rankdir=LR
    label = "Legend";
    key [label=<<table border="0" cellpadding="2" cellspacing="0" cellborder="0">
      <tr><td align="right" port="i1">main branches</td></tr>
      <tr><td align="right" port="i2">pruned branches</td></tr>
      <tr><td align="right" port="i3">merge</td></tr>
      </table>>]
    key2 [label=<<table border="0" cellpadding="2" cellspacing="0" cellborder="0">
      <tr><td port="i1">&nbsp;</td></tr>
      <tr><td port="i2">&nbsp;</td></tr>
      <tr><td port="i3">&nbsp;</td></tr>
      </table>>]
    key:i1:e -> key2:i1:w [style=bold,color=blue];
    key:i2:e -> key2:i2:w [style=solid,color=black];
    key:i3:e -> key2:i3:w [style=dotted,color=black];
  }
  #edges
EOF

echo "$header"
git log --all --no-merges --first-parent --min-parents=1 --pretty='format:"%p" -> "%h" [style=bold,color=red,label="%aN"];'
git log --all --no-merges --min-parents=1 --pretty='format:"%p" -> "%h" [label="%aN"];'
git log --all --merges --pretty='format:%h %p'| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,";\n{",$3,$4,"} ->",$1,"[style=dotted];"}'
git log --all --merges --first-parent --pretty='format:%h %p'| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,"[style=bold,color=red];\n{",$3,$4,"} ->",$1,"[style=dotted];"}'
if [ ! -z "$1" ]
then
 git log --first-parent --min-parents=1 --pretty='format:%h %p' master testing| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,"[style=bold,color=purple];"}'
 git log --first-parent --min-parents=1 --pretty='format:%h %p' develop| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,"[style=bold,color=blue];"}'
else
 git log --branches --tags --first-parent --min-parents=1 --pretty='format:%h %p'| sed -E 's/([^ ]+)/"\1"/g' | awk '{print $2,"->",$1,"[style=bold,color=blue];"}'
fi
echo '#refs'
git log --decorate=short --no-walk --remotes --pretty='format: "%h" [label="%h %d",style=filled,color="lightblue"];'|sed 's/origin\///g'
git log --decorate=short --no-walk --tags --pretty='format: "%h" [label="%h %d",style=filled,color="green"];'
git log --decorate=short --no-walk --branches --pretty='format: "%h" [label="%h %d",style=filled,color="yellow"];'|sed -E 's/origin\/.*, //g'|sed 's/, origin\/.*)/)/g' | sed 's/HEAD -> //g'
if [ ! -z "$URL" ]
then
  git log --all --pretty='format: "%h" [URL="'$URL'%h"];'
fi
echo '}'
