from utils import sql_test_runner


def test_min_semester_for_course(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "min_semester_for_course", snapshot, db_connection)


def test_students_with_many_enrolments(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "students_with_many_enrolments", snapshot, db_connection)


def test_top_3_students(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "top_3_students", snapshot, db_connection)
