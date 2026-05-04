cat /tmp/scripts/create-campus-tables.sql | psql -U postgres

psql -U postgres -c "copy person (first_name, last_name, birth_date, phone_number, email) from '/tmp/data/person_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy professor (status, job, person_id) from '/tmp/data/professor_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy student_group (name, start_year) from '/tmp/data/student_group_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy student (course, start_date, end_date, status, form_of_study, finance_source, person_id, tutor, group_id) from '/tmp/data/student_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy student_curator (student_id, group_id) from '/tmp/data/student_curator_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy student_lead (student_id, group_id) from '/tmp/data/student_lead_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy course (name, hours, credits, control_type, study_type, status) from '/tmp/data/course_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy course_prerequisite (course_id, prerequisite_course_id) from '/tmp/data/course_prerequisite_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy course_teacher (course_id, professor_id, professor_role) from '/tmp/data/course_teacher_base.csv' delimiter ',' CSV header;"
psql -U postgres -c "copy enrolment (student_id, course_id, grade, enrolment_date, start_year, status) from '/tmp/data/enrolment_base.csv' delimiter ',' CSV header;"

pg_dump -Fc -U postgres postgres > /tmp/dumps/base.dump
