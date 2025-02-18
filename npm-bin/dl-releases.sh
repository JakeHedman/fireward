#!/bin/bash
set -ev

v=$(cd .. && stack exec fireward -- -V)
export files=(fireward-linux fireward-osx fireward.exe)

for f in ${files[*]}; do
  echo "downloading $f"
  curl -L https://github.com/bijoutrouvaille/fireward/releases/download/$v/$f -o $f
  chmod 755 $f
done

# curl -L https://github.com/bijoutrouvaille/fireward/releases/download/$v/fireward-linux -o fireward-linux
# curl -L https://github.com/bijoutrouvaille/fireward/releases/download/$v/fireward-osx -o fireward-osx
# curl -L https://github.com/bijoutrouvaille/fireward/releases/download/$v/fireward.exe -o fireward.exe

