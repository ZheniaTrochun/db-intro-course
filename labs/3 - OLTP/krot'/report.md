# SELECT
`select name, id from item_template where id=2`
[image](1select.png)

# INSERT
`insert into item_template (name, description, max_stack, rarity, type)
values ('Lalala', 'lalalalala', 68, 1, 'food');`
[image](2insert.png)

# UPDATE
`update item_template 
set name='sdvnhodsvnh', max_stack=68 
where id=4;`
[image](3update.png)

# DELETE
`delete from item_template where max_stack=68 and id!=4;`
[image](delete.png)