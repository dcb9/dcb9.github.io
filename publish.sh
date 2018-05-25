sh ./build.sh

cd /tmp/dcb9.github.io/

git init
git add .
git commit -a -m 'Init'

git remote add origin git@github.com:dcb9/dcb9.github.io.git
git push -f origin master
