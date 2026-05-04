#!/bin/bash

if [ ! -f ./tests/venv/bin/activate ]; then
  python -m venv ./tests/venv
  source ./tests/venv/bin/activate
  pip install -r ./tests/requirements.txt
else
  source ./tests/venv/bin/activate
  pip install -r ./tests/requirements.txt
fi

if [ ! -f ../dumps/10k.dump ]; then
  curl -L --fail -o ../dumps/10k.dump https://github.com/ZheniaTrochun/db-intro-course/releases/download/exercises-fixture-v1/10k.dump
fi

cd ./tests || exit

pytest --html=test_results/report_base.html --json-report --json-report-file=test_results/report_base.json --snapshot base --no-header -v
pytest --html=test_results/report_10k.html --json-report --json-report-file=test_results/report_10k.json --snapshot 10k --no-header -v

deactivate

cd ..
