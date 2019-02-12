#!/bin/sh

usage () {
    cat <<EOF

  __  __  ____  ___  _  _  __  ___  ____ 
 / _)(  )(_  _)/ __)( )( )/  \(  ,)(_  _)
( (/\ )(   )(  \__ \ )__(( () ))  \  )(  
 \__/(__) (__) (___/(_)(_)\__/(_)\_)(__) 


 Create short or vanity urls with git.io
 usage: $(basename $0) http://github.com/something [-v mini]
 
 options:
  -v   desired vanity 
  -h   display this screen
EOF
  exit 0
}

err() {
  echo $1
  usage
}

optstest() {
  found=0
  for arg in "$@"
  do
    if echo $arg | awk -F '/' '$3 !~ /github.com|github.io|githubusercontent.com/ { exit 1 }'
    then
      GHURL=$arg
      found=1
    elif [ $arg = "-h" ]
    then
      usage
    elif [ $arg = "-v" ]
    then
      :
    else
      VANITY=$arg
    fi
  done
  if [ $found = 0 ]
  then
    err " must be a valid github.com url!"
  fi
}

case $# in
  1)
    optstest $1 ;;
  3)
    optstest $1 $2 $3 ;;
  *)
    err " invalid number of arguments!" ;;
esac

if [ -z "$VANITY" ]
then
  url=`curl -is https://git.io -F "url=$GHURL" | awk '/Location:/ { print $2 }'`
else
  url=`curl -is https://git.io -F "url=$GHURL" -F "code=$VANITY" | awk '/Location:/ { print $2 }'`
fi

if [ -z $url ]
then
  err " must be a valid github.com url!"
else
  echo $url
fi