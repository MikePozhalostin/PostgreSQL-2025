-- Создание бд
create database bkp;

-- Создание оригинальной таблицы с данными
create table student as 
select 
  generate_series(1,10) as id,
  md5(random()::text)::char(10) as fio;

-- Создание бэкапа таблицы
copy student
TO '/var/lib/postgresql/backups/student_copy.csv'
WITH (FORMAT csv, HEADER);

-- Создание копии таблицы для демонстрации восстановления
create table student_copy (like student);

-- Заполнение копии таблицы из бэкапа
COPY student_copy
FROM '/var/lib/postgresql/backups/student_copy.csv'
WITH (FORMAT csv, HEADER);

