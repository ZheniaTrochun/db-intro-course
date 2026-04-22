from utils import sql_test_runner


def test_min_semester_for_course(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "min_semester_for_course", snapshot, db_connection)


def test_students_with_many_enrollments(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "students_with_many_enrollments", snapshot, db_connection)


def test_top_5_students(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "top_5_students", snapshot, db_connection)


def test_above_average_students_per_group(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "above_average_students_per_group", snapshot, db_connection)


def test_busiest_teachers(snapshot, db_connection):
    sql_test_runner.run_single_exercise("subqueries", "busiest_teachers", snapshot, db_connection)
