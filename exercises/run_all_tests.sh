#!/bin/bash

if [ ! -f ./tests/venv/bin/activate ]; then
  python3 -m venv ./tests/venv
  source ./tests/venv/bin/activate
  pip3 install -r ./tests/requirements.txt
else
  source ./tests/venv/bin/activate
  pip3 install -r ./tests/requirements.txt
fi

if [ ! -f ../dumps/10k.dump ]; then
  curl -L --fail -o ../dumps/10k.dump https://github.com/ZheniaTrochun/db-intro-course/releases/download/exercises-fixture-v2/10k.dump
fi

if [ ! -d ./tests/golden_snapshots/10k/ ]; then
  curl -L --fail -o ./tests/golden_snapshots/10k.zip https://github.com/ZheniaTrochun/db-intro-course/releases/download/exercises-fixture-v2/10k.zip
  unzip ./tests/golden_snapshots/10k.zip -d ./tests/golden_snapshots
  rm ./tests/golden_snapshots/10k.zip
fi

cd ./tests || exit

pytest --html=test_results/report_base.html --json-report --json-report-file=test_results/report_base.json --snapshot base --no-header -v
pytest --html=test_results/report_10k.html --json-report --json-report-file=test_results/report_10k.json --snapshot 10k --no-header -v

deactivate

cd ..
