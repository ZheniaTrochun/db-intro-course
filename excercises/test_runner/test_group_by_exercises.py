from utils import sql_test_runner


def test_student_success_rate(snapshot):
    sql_test_runner.run_single_exercise("group_by", "1", snapshot)


def test_student_average_grade(snapshot):
    sql_test_runner.run_single_exercise("group_by", "2", snapshot)


def test_enrolment_stats(snapshot):
    sql_test_runner.run_single_exercise("group_by", "3", snapshot)
