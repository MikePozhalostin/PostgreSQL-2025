create table orders (
    id int,
    user_id int,
    order_date date,
    status text,
    some_text text
);

insert into orders(id, user_id, order_date, status, some_text)
select generate_series, (random() * 70), date'2019-01-01' + (random() * 300)::int as order_date
        , (array['returned', 'completed', 'placed', 'shipped'])[(random() * 4)::int]
        , concat_ws(' ', (array['go', 'space', 'sun', 'London'])[(random() * 5)::int]
            , (array['the', 'capital', 'of', 'Great', 'Britain'])[(random() * 6)::int]
            , (array['some', 'another', 'example', 'with', 'words'])[(random() * 6)::int]
            )
from generate_series(100001, 1000000);

-- Полная выборка
select * from orders;

-- План для выборки по user_id 
explain analyze select * from orders where user_id = 60;

-- Индекс по user_id
create index idx_user_id on orders (user_id);

-- План для выборки по user_id 
explain analyze select * from orders where user_id = 60;

-- Создание столбца ts_vector
alter table orders add column some_text_lexeme tsvector;
update orders
set some_text_lexeme = to_tsvector(some_text);

-- Gin индекс для полнотекстового поиска
create index idx_search_text on orders using gin (some_text_lexeme);
explain analyze select * from orders where some_text_lexeme @@ to_tsquery('Britain');

-- индекс на часть таблицы
create index idx_part_date on orders (order_date) where order_date < '2019-08-11';
explain analyze select * from orders where order_date = '2019-08-10';
explain analyze select * from orders where order_date = '2019-08-12';

-- составной индекс
create index idx_user_id_and_date on orders (user_id, order_date);
explain analyze select user_id, order_date from orders;