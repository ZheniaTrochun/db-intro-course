from functools import reduce
from pathlib import Path
import pytest
import polars as pl


def print_diff(expected_result: pl.DataFrame, actual_result: pl.DataFrame) -> None:
    print("DataFrames do not match.\n\n")
    # print(f"======== Expected result (first 5 rows) ========")
    # print(expected_result.head(5))
    # print()
    # print(f"======== Actual result (first 5 rows) ========")
    # print(actual_result.head(5))
    print(f"======== Unmatched rows (first 5 rows) ========")
    cols = expected_result.columns

    compare_conditions = [pl.col(c) != pl.col(f"{c}_right") for c in cols]
    compiled_filter = reduce(lambda a, b: a | b, compare_conditions)

    not_matched_df = (actual_result.with_row_index()
                      .join(expected_result.with_row_index(), on="index", how="inner")
                      .filter(compiled_filter)
                      .sort(by="index")
                      .head(5))

    actual_cols_to_select = [pl.col(c) for c in cols]
    expected_cols_to_select = [pl.col(f"{c}_right").alias(c) for c in cols]

    actual = not_matched_df.select([pl.col("index").alias("row_number")] + actual_cols_to_select)
    expected = not_matched_df.select([pl.col("index").alias("row_number")] + expected_cols_to_select)

    print("Expected:")
    print(actual)
    print()
    print("To be equal to:")
    print(expected)
    print()


def validate_query_output(
        exercise_group: str,
        exercise: str,
        actual_result: pl.DataFrame,
        snapshot_name: str = "base",
        check_order: bool = True
):
    snapshot_path = Path(__file__).parent.parent / "golden_snapshots" / exercise_group / f"{exercise}_{snapshot_name}.csv"

    assert snapshot_path.exists(), \
        f"Golden snapshot not found: {snapshot_path}"

    expected_result = pl.read_csv(snapshot_path)

    expected_columns = expected_result.columns
    actual_columns = actual_result.columns

    assert list(expected_columns).sort() == list(actual_columns).sort(), \
        f"Columns mismatch. Expected: {expected_columns}. Actual: {actual_columns}"

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
