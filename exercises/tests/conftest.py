import pytest
from testcontainers.postgres import PostgresContainer
import psycopg
from pathlib import Path
import yaml


def pytest_addoption(parser):
    parser.addoption("--snapshot", action="store", default="base")


@pytest.fixture(scope="session")
def snapshot(request):
    return request.config.option.snapshot

@pytest.fixture(scope="session")
def postgres_container(snapshot):
    path_to_dumps = Path(__file__).parent / "data"

    config = read_config()['postgres']

    with PostgresContainer(
            f"postgres:{config['version']}",
            username=config['user'],
            password=config['password'],
            dbname=config['dbname'],
            driver='psycopg',
            volumes=[(str(path_to_dumps.absolute()), "/tmp/dumps", "ro")]
    ) as container:
        container.exec(f"pg_restore -U {config['user']} --clean -d postgres /tmp/dumps/{snapshot}.dump")
        yield container


@pytest.fixture
def db_connection(postgres_container):
    conn = psycopg.connect(
        dbname=postgres_container.dbname,
        user=postgres_container.username,
        password=postgres_container.password,
        host=postgres_container.get_container_host_ip(),
        port=postgres_container.get_exposed_port(5432)
    )
    yield conn
    conn.close()


def read_config():
    with open("config.yaml", "r") as f:
        return yaml.safe_load(f)
