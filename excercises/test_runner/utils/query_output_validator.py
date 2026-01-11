from pathlib import Path
import pytest
import polars as pl


def cast_everything_to_string(dataframe: pl.DataFrame) -> pl.DataFrame:
    cols = dataframe.columns

    return dataframe.select([pl.col(c).cast(pl.Utf8) for c in cols])


def print_diff(expected_result: pl.DataFrame, actual_result: pl.DataFrame) -> None:
    print("DataFrames do not match.\n\n")
    print(f"======== Expected result ========")
    print(expected_result.head(5))
    print()
    print(f"======== Actual result ========")
    print(actual_result.head(5))
    print()


def validate_query_output(
        exercise_group: str,
        exercise: str,
        actual_result: pl.DataFrame,
        snapshot_name: str = "base",
        check_order: bool = True
) -> tuple[bool, str]:
    snapshot_path = Path(__file__).parent.parent / "golden_snapshots" / exercise_group / f"{exercise}_{snapshot_name}.csv"

    assert snapshot_path.exists(), \
        f"Golden snapshot not found: {snapshot_path}"

    expected_result = pl.read_csv(snapshot_path)

    expected_columns = expected_result.columns
    actual_columns = actual_result.columns

    assert list(expected_columns).sort() == list(actual_columns).sort(), \
        f"Columns mismatch. Expected: {expected_columns}. Actual: {actual_columns}"

    expected_result = cast_everything_to_string(expected_result)
    actual_result = cast_everything_to_string(actual_result)

    assert actual_result.height > 0, "SQL query returned 0 rows."

    is_rows_number_match = expected_result.height == actual_result.height

    if not is_rows_number_match:
        print_diff(expected_result, actual_result)
        pytest.fail(f"Number of rows mismatch. Expected: {expected_result.height}. Actual: {actual_result.height}.")

    if not check_order:
        expected_result = expected_result.sort(by=expected_columns)
        actual_result = actual_result.sort(by=actual_columns)

    res = expected_result.equals(actual_result)

    if not res:
        print_diff(expected_result, actual_result)
        pytest.fail(f"Expected and actual results do not match.")
