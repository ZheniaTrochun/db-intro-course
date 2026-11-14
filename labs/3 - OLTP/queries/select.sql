-- song
-- пісні з мовою
select s.name, s.author, l.language
from song s
join song_language l on l.id = s.language_id
order by s.name;

-- пісні з нотатками
select s.name, n.note
from song s
left join note n on n.song_id = s.id
order by s.name;

-- пісні без нотаток
select s.name
from song s
left join note n on n.song_id = s.id
where n.id is null;

-- song_language
-- мови з кількістю пісень
select l.language, count(s.id) as songs
from song_language l
left join song s on s.language_id = l.id
group by l.language
order by songs desc;

-- мови з перекладеними піснями
select distinct l.language
from song_language l
join song s on s.language_id = l.id
where s.is_translated;

-- church
-- церкви з кількістю богослужінь
select c.name, c.location, count(w.id) as worships
from church c
left join worship w on w.church_id = c.id
group by c.id, c.name, c.location
order by worships desc;

-- церкви з сумарними переглядами
select c.name, c.location, coalesce(sum(w.views), 0) as total_views
from church c
left join worship w on w.church_id = c.id
group by c.id, c.name, c.location
order by total_views desc;

-- церкви та пісні, виконані на їхніх богослужіннях
select c.name as church, s.name as song, count(g.id) as times_sang
from church c
join worship w on w.church_id = c.id
join singing g on g.worship_id = w.id
join song s on s.id = g.song_id
group by c.name, s.name
order by c.name, times_sang desc;

-- worship_types
-- типи з кількістю богослужінь
select t.type, count(w.id) as worships
from worship_types t
left join worship w on w.type_id = t.id
group by t.type
order by worships desc;

-- середні перегляди за типом
select t.type, round(avg(w.views)) as avg_views
from worship_types t
join worship w on w.type_id = t.id
group by t.type
order by avg_views desc;

-- worship
-- богослужіння з церквою та типом
select c.name as church, w.date, t.type, w.views
from worship w
join church c on c.id = w.church_id
join worship_types t on t.id = w.type_id
order by w.date;

-- богослужіння, де виконувалась конкретна пісня
select w.date, c.name as church, g.performer
from worship w
join church c on c.id = w.church_id
join singing g on g.worship_id = w.id
join song s on s.id = g.song_id
where s.name = 'Song1'
order by w.date;

-- богослужіння з кількістю пісень
select w.date, c.name as church, count(g.id) as songs_count
from worship w
join church c on c.id = w.church_id
left join singing g on g.worship_id = w.id
group by w.id, w.date, c.name
order by w.date;

-- note
-- нотатки з піснею та мовою
select s.name as song, l.language, n.note
from note n
join song s on s.id = n.song_id
join song_language l on l.id = s.language_id
order by s.name;

-- пісні з кількістю нотаток
select s.name, count(n.id) as notes
from song s
join note n on n.song_id = s.id
group by s.name
order by notes desc;

-- singing
-- виконання з піснею, мовою, церквою, датою, типом
select s.name as song, l.language, c.name as church, w.date, t.type, g.performer
from singing g
join song s on s.id = g.song_id
join song_language l on l.id = s.language_id
join worship w on w.id = g.worship_id
join church c on c.id = w.church_id
join worship_types t on t.id = w.type_id
order by w.date, s.name;

-- виконавці з кількістю виконань
select g.performer, count(*) as performances
from singing g
group by g.performer
order by performances desc;

-- пісні, виконані більше ніж на одному богослужінні
select s.name, count(distinct g.worship_id) as worships
from singing g
join song s on s.id = g.song_id
group by s.name
having count(distinct g.worship_id) > 1
order by worships desc;
