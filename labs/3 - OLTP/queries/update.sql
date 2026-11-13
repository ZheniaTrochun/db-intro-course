-- worship
-- збільшити перегляди та підписників богослужіння Church1
update worship
set views = views + 100,
    subscribers = subscribers + 50
where link = 'https://youtube.com/watch?v=lab3-1';

-- song
-- позначити Song2 як перекладену
update song
set translator = 'Translator2',
    is_translated = true
where name = 'Song2';

-- note
-- змінити нотатку пісні Song3
update note
set note = 'Updated note for song 3'
where song_id = (select id from song where name = 'Song3');

-- singing
-- змінити виконавця на богослужінні lab3-4 для Song4
update singing
set performer = 'PerformerX'
where worship_id = (select id from worship where link = 'https://youtube.com/watch?v=lab3-4')
  and song_id = (select id from song where name = 'Song4');

-- worship
-- змінити тип богослужіння Church5
update worship
set type_id = (select id from worship_types where type = 'Type1')
where church_id = (select id from church where name = 'Church5');
