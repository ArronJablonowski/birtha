getent passwd |
cut -d : -f 6 |
sed 's:$:/.bash_history:' |
xargs -d '\n' grep -s -H -e "$pattern" 