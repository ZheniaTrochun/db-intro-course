from pathlib import Path

import polars as pl
import pytest
import warnings


def read_query_from_file(path: str) -> str:
    with open(path, "r") as f:
        return f.read()


def execute_query(sql: str, connection) -> pl.DataFrame:
    with connection.cursor() as cursor:
        cursor.execute(sql)

        columns = [desc[0] for desc in cursor.description]

        rows = cursor.fetchall()

        data = { col: [row[i] for row in rows] for i, col in enumerate(columns) }
        return pl.DataFrame(data)


def sanitize_sql(sql: str) -> str:
    lines = sql.strip().split("\n")

    non_commented_lines = [line for line in lines if not line.strip().startswith("--")]
    sql_without_comments = "\n".join(non_commented_lines)

    separate_queries = [query.strip() for query in sql_without_comments.split(";") if query.strip() != ""]
    if len(separate_queries) > 1:
        print(separate_queries)
        warnings.warn("SQL file contains multiple queries. Only the last one will be executed.")
        return separate_queries[-1]
    else:
        return sql_without_comments.strip()


def execute(exercise_group: str, exercise: str, db_connection) -> pl.DataFrame:
    base_path = Path(__file__).parent.parent.parent
    script_path = base_path / exercise_group / f"{exercise}.sql"

    if not script_path.exists():
        pytest.fail(f"Error: Script not found: {script_path}")

    path = str(script_path.resolve())

    raw_sql = read_query_from_file(path)

    sanitized_sql = sanitize_sql(raw_sql)

    if sanitized_sql.strip() == "":
        pytest.skip(f"SQL for {exercise_group} / {exercise} is empty.")
    else:
        print("Executing query:")
        print(sanitized_sql)
        print()

        return execute_query(sanitized_sql, db_connection)
