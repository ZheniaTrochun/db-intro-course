select
    c.club_name,
    count(bt.table_id) as table_count
from club c
    join billiard_table bt using (club_id)
group by c.club_id, c.club_name
order by table_count desc;

select
    u.first_name || ' ' || u.last_name as player_name,
    p.rating,
    round(avg(p.rating) over (), 2)    as global_avg_rating
from player p
    join users u on p.person_id = u.user_id
where p.rating is not null
order by p.rating desc;

select
    u.first_name || ' ' || u.last_name                         as player_name,
    p.sports_title,
    p.rating,
    round(avg(p.rating) over (partition by p.sports_title), 2) as avg_title_rating
from player p
    join users u on p.person_id = u.user_id
where p.rating is not null
order by p.sports_title, p.rating desc;

select
    u.first_name || ' ' || u.last_name as player_name,
    sum(tr.prize_won)                  as total_prize_won
from player p
    join users u on p.person_id = u.user_id
    join tournament_registration tr using (player_id)
group by p.player_id, u.first_name, u.last_name
having sum(tr.prize_won) > 5000.00
order by total_prize_won desc;

select
    c.club_name,
    count(t.tournament_id) as tournament_count,
    sum(t.prize_pool)      as total_prize_pool
from club c
    join tournament t using (club_id)
group by c.club_id, c.club_name
order by total_prize_pool desc;

select
    c.club_name,
    bt.table_number,
    bt.table_type,
    bt.table_status
from billiard_table bt
    join club c using (club_id)
    left join match m using (table_id)
where m.match_id is null
order by c.club_name, bt.table_number;

select
    p1.player_id                         as player_1_id,
    u1.first_name || ' ' || u1.last_name as player_1_name,
    p2.player_id                         as player_2_id,
    u2.first_name || ' ' || u2.last_name as player_2_name
from player p1
    join users u1 on p1.person_id = u1.user_id
    cross join player p2
    join users u2 on p2.person_id = u2.user_id
where p1.player_id < p2.player_id
order by p1.player_id, p2.player_id;

select
    u.first_name || ' ' || u.last_name as player_name,
    p.sports_title,
    p.rating
from player p
    join users u on p.person_id = u.user_id
where p.rating > (
    select avg(rating)
    from player
)
order by p.rating desc;

select
    u.first_name || ' ' || u.last_name          as player_name,
    p.rating,
    (select max(rating) from player)            as max_rating,
    (select max(rating) from player) - p.rating as diff_from_max
from player p
    join users u on p.person_id = u.user_id
where p.rating is not null
order by p.rating desc;

select
    c.club_name,
    round(avg(t.prize_pool), 2) as avg_club_prize_pool
from club c
    join tournament t using (club_id)
group by c.club_id, c.club_name
having avg(t.prize_pool) > (
    select avg(prize_pool)
    from tournament
)
order by avg_club_prize_pool desc;
