from utils import sql_test_runner


def test_students_at_risk(snapshot, db_connection):
    sql_test_runner.run_single_exercise("joins", "students_at_risk", snapshot, db_connection)


def test_course_teachers(snapshot, db_connection):
    sql_test_runner.run_single_exercise("joins", "course_teachers", snapshot, db_connection)


def test_professor_not_curator(snapshot, db_connection):
    sql_test_runner.run_single_exercise("joins", "professor_not_curator", snapshot, db_connection)


def test_course_prerequisites(snapshot, db_connection):
    sql_test_runner.run_single_exercise("joins", "course_prerequisites", snapshot, db_connection)


def test_university_activities(snapshot, db_connection):
    sql_test_runner.run_single_exercise("joins", "university_activities", snapshot, db_connection)
