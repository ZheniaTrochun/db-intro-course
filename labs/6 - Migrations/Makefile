.SILENT: help run_deamon stop_deamon run_db stop_db
.PHONY: help run_deamon stop_deamon run_db stop_db
.DEFAULT_GOAL := help

help:
	echo "bun gen --name <migration_name>"
	echo "bun up"
	echo "sudo make run_deamon"
	echo "sudo make stop_deamon"
	echo "sudo make run_db"
	echo "sudo make stop_db"

run_deamon:
	./grant_sudo.sh && dockerd &

stop_deamon:
	./grant_sudo.sh && pkill dockerd

run_db:
	./grant_sudo.sh && docker run --rm --name lab6-pg -p 5433:5432 -e POSTGRES_PASSWORD=mypass -e POSTGRES_USER=postgres -e POSTGRES_DB=your_database_name -d postgres:18.6-alpine3.24

stop_db:
	./grant_sudo.sh && sh -c "docker stop $$(docker ps -q -f "name=lab6-pg")"
