#!/bin/bash

if [ ! -f ./test_runner/venv ]; then
  python3 -m venv ./test_runner/venv
  source ./test_runner/venv/bin/activate
  pip3 install -r ./test_runner/requirements.txt
fi

cd ./test_runner || exit

pytest --html=test_results/report.html --json-report --json-report-file=test_results/report.json --snapshot base --no-header -v
pytest --html=test_results/report.html --json-report --json-report-file=test_results/report.json --snapshot 10k --no-header -v
pytest --html=test_results/report.html --json-report --json-report-file=test_results/report.json --snapshot 100k --no-header -v

deactivate

cd ..
