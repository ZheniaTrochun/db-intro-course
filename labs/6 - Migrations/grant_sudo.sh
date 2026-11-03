#/usr/bin/env bash

[ "$(whoami)" != "root" ] && \
  echo "You are not root, run this target as root please" && \
  exit 1
true
