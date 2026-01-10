import sys
from pathlib import Path

import query_executor
import query_output_validator
import argparse
import os


def process_single_exercise(
        exercise_group: str,
        exercise: str,
        connection_configs: dict[str, str],
        snapshot_name: str = "base",
        no_order: bool = False,
        verbose: bool = False
) -> bool:
    print(f"{exercise_group} / {exercise}: verifying...")
    query_result = query_executor.execute(exercise_group, exercise, connection_configs)

    is_success, details = query_output_validator.validate_query_output(
        exercise_group,
        exercise,
        query_result,
        snapshot_name,
        not no_order
    )
    print(details)
    print(f"{exercise_group} / {exercise}: {'***PASSED***' if is_success else '***FAILED***'}")

    if verbose:
        base_dir = Path(__file__).parent / "test_results" / exercise_group
        os.makedirs(base_dir, exist_ok=True)
        query_result.write_csv(base_dir / f"{exercise}_{snapshot_name}.csv")

    return is_success


def list_all_exercise_groups() -> list[str]:
    base_path = Path(__file__).parent.parent
    return [dir for dir in os.listdir(base_path) if dir != "test_runner" and os.path.isdir(base_path / dir)]


def list_all_exercises_in_group(exercise_group: str) -> list[str]:
    base_path = Path(__file__).parent.parent / exercise_group

    if not base_path.exists():
        print(f"Error: Group not found: {exercise_group}")
        sys.exit(1)

    return [f.removesuffix(".sql") for f in os.listdir(base_path) if os.path.isfile(base_path / f)]


def main():
    parser = argparse.ArgumentParser(
        description="Run SQL query tests against golden snapshots"
    )

    parser.add_argument(
        "exercise_group",
        nargs="?",
        help="Test group (group_by/subqueries/etc) (optional, runs all if not provided)",
    )
    parser.add_argument(
        "exercise",
        nargs="?",
        help="Specific test in a group (optional, runs all if not provided)",
    )
    parser.add_argument(
        "--snapshot_name",
        default="base",
        help="Specific name of a snapshot to test against (default: base)",
    )

    parser.add_argument(
        "--no-order",
        action="store_true",
        help="Ignore row order when comparing results",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Show verbose output",
    )
    parser.add_argument(
        "--host",
        default=os.environ.get("PG_HOST", "localhost"),
        help="PostgreSQL host (default: localhost)",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=int(os.environ.get("PG_PORT", "5432")),
        help="PostgreSQL port (default: 5432)",
    )
    parser.add_argument(
        "--user",
        default=os.environ.get("PG_USER", "postgres"),
        help="PostgreSQL user (default: postgres)",
    )
    parser.add_argument(
        "--password",
        default=os.environ.get("PG_PASSWORD", "password123"),
        help="PostgreSQL password (default: password123)",
    )
    parser.add_argument(
        "--dbname",
        default=os.environ.get("PG_DB", "postgres"),
        help="PostgreSQL database name (default: postgres)",
    )

    args = parser.parse_args()

    connection_configs = {
        "PG_HOST": args.host,
        "PG_PORT": args.port,
        "PG_USER": args.user,
        "PG_PASSWORD": args.password,
        "PG_DB": args.dbname
    }

    if args.exercise_group:
        if args.exercise:
            is_success = process_single_exercise(args.exercise_group, args.exercise, connection_configs, args.snapshot_name, args.no_order, args.verbose)
            print(f"{'***PASSED***' if is_success else f'***FAILED***'}")
            sys.exit(0 if is_success else 1)
        else:
            exercises = list_all_exercises_in_group(args.exercise_group)
            results = [process_single_exercise(args.exercise_group, exercise, connection_configs, args.snapshot_name, args.no_order, args.verbose) for exercise in exercises]
            is_success = all(results)
            failures = len([res for res in results if not res])

            print(f"{args.exercise_group}: {'***PASSED***' if is_success else f'***FAILED*** ({failures} tests failed)'}")
            sys.exit(0 if is_success else 1)
    else:
        exercise_groups = list_all_exercise_groups()
        results = []
        failure_counter = 0

        for exercise_group in exercise_groups:
            exercises = list_all_exercises_in_group(exercise_group)
            group_results = []

            for exercise in exercises:
                is_success = process_single_exercise(exercise_group, exercise, connection_configs, args.snapshot_name, args.no_order, args.verbose)
                group_results.append(is_success)

            is_success = all(group_results)
            failures = len([res for res in group_results if not res])

            print(f"{exercise_group}: {'***PASSED***' if is_success else f'***FAILED*** ({failures} tests failed in {exercise_group})'}")
            failure_counter += failures

            results.append(is_success)

        is_success = all(results)
        print(f"{'***PASSED***' if is_success else f'***FAILED*** ({failure_counter} tests failed in total)'}")

        sys.exit(0 if is_success else 1)


if __name__ == "__main__":
    main()
