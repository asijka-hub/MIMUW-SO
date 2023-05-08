#!/bin/bash
cd tests

function run {
  if ! clang -O2 -o test $1; then
    printf "compilation ERROR $1\n"
    exit 1
  fi
  ./test
  code=$?

  if [ $code -eq 0 ]; then
    printf "OK\n"
    rm test
    return 0
  else
    printf "test ERROR\n"
    exit 1
  fi
}

for file in $(ls *.c); do
  echo -n "$file "
  run "$file" 2> /dev/null
done

/sbin/poweroff

