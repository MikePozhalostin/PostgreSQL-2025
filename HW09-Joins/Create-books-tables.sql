-- 1. Создание таблиц
CREATE TABLE books.authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100)
);

CREATE TABLE books.books (
    id SERIAL PRIMARY KEY,
    author_id INT NOT NULL REFERENCES books.authors(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    published_year INT
);

CREATE TABLE books.reviews (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books.books(id) ON DELETE CASCADE,
    reviewer VARCHAR(100),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT
);

-- 2. Заполнение таблицы authors (10 строк)

INSERT INTO books.authors (name, country) VALUES
('Лев Толстой', 'Россия'),
('Фёдор Достоевский', 'Россия'),
('Джордж Оруэлл', 'Великобритания'),
('Агата Кристи', 'Великобритания'),
('Эрнест Хемингуэй', 'США'),
('Марк Твен', 'США'),
('Жюль Верн', 'Франция'),
('Габриэль Гарсиа Маркес', 'Колумбия'),
('Артур Конан Дойл', 'Великобритания'),
('Харуки Мураками', 'Япония'),
('Александр Пушкин', 'Россия');

-- 3. Заполнение таблицы books (10 строк)

INSERT INTO books.books (author_id, title, published_year) VALUES
(1, 'Война и мир', 1869),
(1, 'Анна Каренина', 1877),
(2, 'Преступление и наказание', 1866),
(2, 'Идиот', 1869),
(3, '1984', 1949),
(4, 'Убийство в Восточном экспрессе', 1934),
(5, 'Старик и море', 1952),
(6, 'Приключения Тома Сойера', 1876),
(7, '20 000 лье под водой', 1870),
(9, 'Собака Баскервилей', 1902),;

-- 4. Заполнение таблицы reviews (10 строк)

INSERT INTO books.reviews (book_id, reviewer, rating, review_text) VALUES
(1, 'Иван', 5, 'Великолепное произведение.'),
(2, 'Мария', 4, 'Глубокая и драматичная история.'),
(3, 'Павел', 5, 'Философски насыщенная книга.'),
(4, 'Ольга', 4, 'Интересный сюжет и персонажи.'),
(5, 'Антон', 5, 'Классика антиутопий.'),
(6, 'Елена', 4, 'Захватывающий детектив.'),
(7, 'Сергей', 5, 'Очень сильная и трогательная вещь.'),
(8, 'Ирина', 4, 'Весёлая и лёгкая книга.'),
(9, 'Тимур', 5, 'Фантастика, опередившая своё время.'),
(10,'Алексей', 4, 'Классический английский детектив.');