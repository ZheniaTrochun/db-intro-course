#/usr/bin/env bash

echo "" > ./migration-notes.md

for i in ./notes/2026*.md; do
  echo >> ./migration-notes.md
  cat "$i" >> ./migration-notes.md
  echo >> ./migration-notes.md
done
