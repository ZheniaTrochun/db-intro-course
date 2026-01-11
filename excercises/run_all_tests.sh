#!/bin/bash

docker-compose -f ./test_runner/docker-compose.tests.yml up -d

sleep 1

if [ ! -f ./test_runner/venv ]; then
  python3 -m venv ./test_runner/venv
  source ./test_runner/venv/bin/activate
  pip3 install -r ./test_runner/requirements.txt
fi

docker-compose -f ./test_runner/docker-compose.tests.yml exec db bash -c 'pg_restore -U postgres --clean -d postgres < /tmp/dumps/base.dump > /dev/null 2>&1'
PG_PORT="5434" pytest --html=test_results/report.html --json-report --json-report-file=test_results/report.json --snapshot base --no-header -v

docker-compose -f ./test_runner/docker-compose.tests.yml exec db bash -c 'pg_restore -U postgres --clean -d postgres < /tmp/dumps/10k.dump > /dev/null 2>&1'
PG_PORT="5434" pytest --html=test_results/report.html --json-report --json-report-file=test_results/report.json --snapshot 10k --no-header -v

docker-compose -f ./test_runner/docker-compose.tests.yml exec db bash -c 'pg_restore -U postgres --clean -d postgres < /tmp/dumps/100k.dump > /dev/null 2>&1'
PG_PORT="5434" pytest --html=test_results/report.html --json-report --json-report-file=test_results/report.json --snapshot 100k --no-header -v

deactivate

docker-compose -f ./test_runner/docker-compose.tests.yml down
