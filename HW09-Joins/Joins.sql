-- 1. Прямое соединение двух таблиц books и authors
Select * from books.books
join books.authors on books.author_id = authors.id;

-- 2. Правостороннее соединение таблиц books и authors
Select * from books.books
right join books.authors on books.author_id = authors.id;

-- 3. Кросс соединение двух таблиц books и reviews
Select * from books.books
cross join books.reviews;

-- 4. Полное соединение двух таблиц books и reviews
Select * from books.books
full join books.reviews on books.id = reviews.book_id;;

-- 5. Запрос, в котором будут использованы разные типы соединений.
-- Выборка ревью книг с авторами (скрин /images/Many_joins.png)
Select au.name, bk.title, bk.published_year, rw.reviewer, rw.rating, rw.review_text
from books.books as bk
right join books.authors as au on bk.author_id = au.id
full join books.reviews as rw on bk.id = rw.book_id;;

-- 7. Диаграмма таблиц /images/Books-diagramm.png