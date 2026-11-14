-- агрегація
-- загальна статистика богослужінь
select count(*) as worships,
       sum(views) as total_views,
       round(avg(views)) as avg_views,
       min(views) as min_views,
       max(views) as max_views
from worship;

-- богослужіння та перегляди за церквами
select c.name as church, count(w.id) as worships, sum(w.views) as total_views
from church c
join worship w on w.church_id = c.id
group by c.name
order by total_views desc;

-- середні перегляди за типом
select t.type, round(avg(w.views)) as avg_views
from worship_types t
join worship w on w.type_id = t.id
group by t.type
order by avg_views desc;

-- церкви із сумарними переглядами понад 600
select c.name as church, sum(w.views) as total_views
from church c
join worship w on w.church_id = c.id
group by c.name
having sum(w.views) > 600
order by total_views desc;

-- джоіни
-- inner join: хто що співав і в якій церкві
select s.name as song, c.name as church, g.performer
from singing g
join song s on s.id = g.song_id
join worship w on w.id = g.worship_id
join church c on c.id = w.church_id
order by c.name, s.name;

-- left join: усі церкви, навіть без богослужінь
select c.name as church, count(w.id) as worships
from church c
left join worship w on w.church_id = c.id
group by c.name
order by worships desc;

-- full join: церкви та богослужіння
select c.name as church, w.date
from church c
full join worship w on w.church_id = c.id
order by c.name, w.date;

-- right join: усі типи, навіть без богослужінь
select t.type, w.date
from worship w
right join worship_types t on t.id = w.type_id
order by t.type, w.date;

-- підзапити
-- богослужіння з переглядами вище середнього (підзапит у WHERE)
select c.name as church, w.date, w.views
from worship w
join church c on c.id = w.church_id
where w.views > (select avg(views) from worship)
order by w.views desc;

-- церква та її сумарні перегляди (підзапит у SELECT)
select c.name as church,
       (select sum(w.views) from worship w where w.church_id = c.id) as total_views
from church c
order by total_views desc nulls last;

-- церкви із сумарними переглядами вище середнього по церквах (підзапит у HAVING)
select c.name as church, sum(w.views) as total_views
from church c
join worship w on w.church_id = c.id
group by c.name
having sum(w.views) > (
    select avg(t.total)
    from (select sum(w2.views) as total
          from worship w2
          group by w2.church_id) t
)
order by total_views desc;
