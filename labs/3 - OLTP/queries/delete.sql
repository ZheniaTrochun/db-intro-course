-- note
-- видалити нотатки пісні Song5
delete from note
where song_id = (select id from song where name = 'Song5');

-- singing
-- видалити виконання Song3 на богослужінні lab3-3
delete from singing
where worship_id = (select id from worship where link = 'https://youtube.com/watch?v=lab3-3')
  and song_id = (select id from song where name = 'Song3');

-- worship
-- видалити богослужіння lab3-3, якщо на ньому нічого не співали
delete from worship w
where w.link = 'https://youtube.com/watch?v=lab3-3'
  and not exists (select 1 from singing where worship_id = w.id);

-- church
-- видалити Church3, якщо в неї немає богослужінь
delete from church c
where c.name = 'Church3'
  and not exists (select 1 from worship where church_id = c.id);
