from pathlib import Path

import utils.query_output_validator as query_output_validator
import utils.query_executor as query_executor
import os

def run_single_exercise(exercise_group: str, exercise: str, snapshot_name, db_connection):
    try:
        query_result = query_executor.execute(exercise_group, exercise, db_connection)
    except Exception as e:
        print(f"\n\nError executing query: {e}")
        raise e

    base_dir = Path(__file__).parent.parent / "test_results" / exercise_group
    os.makedirs(base_dir, exist_ok=True)
    query_result.write_csv(base_dir / f"{exercise}_{snapshot_name}.csv")

    try:
        query_output_validator.validate_query_output(
            exercise_group,
            exercise,
            query_result,
            snapshot_name
        )
    except Exception as e:
        print(f"\n\nError validating query output: {e}")
        raise e
