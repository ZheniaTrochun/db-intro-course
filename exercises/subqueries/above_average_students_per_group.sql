WITH student_avg AS (
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        sga.group_id,
        ROUND(AVG(e.grade), 2)             AS avg_grade
    FROM student s
    JOIN person p                     ON p.person_id    = s.person_id
    JOIN student_group_assignment sga ON sga.student_id = s.student_id
    JOIN enrolment e                  ON e.student_id   = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, p.first_name, p.last_name, sga.group_id
),
group_avg AS (
    SELECT
        sga.group_id,
        ROUND(AVG(e.grade), 2) AS avg_grade
    FROM student_group_assignment sga
    JOIN enrolment e ON e.student_id = sga.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY sga.group_id
)
SELECT
    sa.student_id,
    sa.full_name,
    sg.group_name,
    sa.avg_grade AS avg_student_grade,
    ga.avg_grade AS avg_group_grade
FROM student_avg sa
JOIN group_avg ga     ON ga.group_id = sa.group_id
JOIN student_group sg ON sg.group_id = sa.group_id
WHERE sa.avg_grade > ga.avg_grade
ORDER BY sg.group_name, sa.avg_grade DESC, sa.full_name, sa.student_id;