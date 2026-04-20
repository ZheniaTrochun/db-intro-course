#!/bin/bash

if [ ! -f ./tests/venv/bin/activate ]; then
  python3 -m venv ./tests/venv
  source ./tests/venv/bin/activate
  pip3 install -r ./tests/requirements.txt
else
  source ./tests/venv/bin/activate
  pip3 install -r ./tests/requirements.txt
fi

cd ./tests || exit

pytest --html=test_results/report_base.html --json-report --json-report-file=test_results/report_base.json --snapshot base --no-header -v
pytest --html=test_results/report_10k.html --json-report --json-report-file=test_results/report_10k.json --snapshot 10k --no-header -v

deactivate

cd ..
read -p "Тести завершено. Натисни Enter для виходу..."