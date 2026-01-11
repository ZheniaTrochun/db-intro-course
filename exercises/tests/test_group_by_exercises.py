from utils import sql_test_runner


def test_student_success_rate(snapshot, db_connection):
    sql_test_runner.run_single_exercise("group_by", "student_success_rate", snapshot, db_connection)


def test_student_average_grade(snapshot, db_connection):
    sql_test_runner.run_single_exercise("group_by", "student_average_grade", snapshot, db_connection)


def test_enrolment_stats(snapshot, db_connection):
    sql_test_runner.run_single_exercise("group_by", "enrolment_stats", snapshot, db_connection)
