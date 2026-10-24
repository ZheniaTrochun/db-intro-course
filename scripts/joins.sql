
-- скласти список груп ІМ-21 та ІМ-22
select sg.group_name, p.first_name || ' ' || p.last_name as student_name
from student_group sg
         inner join student_group_assignment ga using (group_id)
         inner join student using (student_id)
         inner join person p using (person_id)
where ga.assignment_status = 'active'
  and sg.group_name IN ('ІМ-21', 'ІМ-22')
order by p.last_name;

-- для кожної групи знайти старосту та куратора
select
    sg.group_name,
    lp.first_name || ' ' || lp.last_name as student_lead,
    profp.first_name || ' ' || profp.last_name as curator
from student_group sg
         left join student s on sg.student_lead = s.student_id
         left join professor prof on sg.curator_id = prof.professor_id
         left join person lp on s.person_id = lp.person_id
         left join person profp on prof.person_id = profp.person_id;


select
    sg.group_name,
    profp.first_name || ' ' || profp.last_name as curator
from student_group sg
         left join professor prof on sg.curator_id = prof.professor_id
         left join person profp on prof.person_id = profp.person_id
where sg.group_status = 'active';
