from pathlib import Path

import polars as pl


def cast_everything_to_string(dataframe: pl.DataFrame) -> pl.DataFrame:
    cols = dataframe.columns

    return dataframe.select([pl.col(c).cast(pl.Utf8) for c in cols])


def get_n_diffs(a: pl.DataFrame, b: pl.DataFrame, n: int = 10) -> list[str]:
    diffs = []
    for i in range(a.height):
        if a.row(i) != b.row(i):
            diffs.append(f"Row {i}: {a.row(i)} != {b.row(i)}")
        if len(diffs) >= n:
            break

    return diffs


def validate_query_output(
        exercise_group: str,
        exercise: str,
        actual_result: pl.DataFrame,
        snapshot_name: str = "base",
        check_order: bool = True
) -> tuple[bool, str]:
    snapshot_path = Path(__file__).parent / "golden_snapshots" / exercise_group / f"{exercise}_{snapshot_name}.csv"

    if not snapshot_path.exists():
        return False, f"Golden snapshot not found: {snapshot_path}"

    expected_result = pl.read_csv(snapshot_path)

    expected_columns = expected_result.columns
    actual_columns = actual_result.columns

    if list(expected_columns).sort() != list(actual_columns).sort():
        return False, f"Columns mismatch\n\tExpected: {expected_columns}\n\tActual: {actual_columns}"

    expected_result = cast_everything_to_string(expected_result)
    actual_result = cast_everything_to_string(actual_result)

    if not check_order:
        expected_result = expected_result.sort(by=expected_columns)
        actual_result = actual_result.sort(by=actual_columns)

    if expected_result.equals(actual_result):
        return True, "DataFrames match"
    else:
        diffs = get_n_diffs(expected_result, actual_result)
        return False, f"DataFrames do not match.\n{"\n".join(diffs)}"
