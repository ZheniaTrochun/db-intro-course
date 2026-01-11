from utils import sql_test_runner


def test_student_success_rate(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "1", snapshot, db_connection)


def test_student_average_grade(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "2", snapshot, db_connection)


def test_enrolment_stats(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "3", snapshot, db_connection)
