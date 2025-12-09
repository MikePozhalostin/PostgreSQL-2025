-- Создание новой схемы
DROP SCHEMA IF EXISTS pract_functions CASCADE;
CREATE SCHEMA pract_functions;

-- Указание схемы по умолчанию
SET search_path = pract_functions, publ

-- таблица товары:
CREATE TABLE goods
(
    goods_id    integer PRIMARY KEY,
    good_name   varchar(63) NOT NULL,
    good_price  numeric(12, 2) NOT NULL CHECK (good_price > 0.0)
);

-- заполнение таблицы
INSERT INTO goods (goods_id, good_name, good_price)
VALUES 	(1, 'Спички хозайственные', .50),
		(2, 'Автомобиль Ferrari FXX K', 185000000.01);

-- таблица продажи
CREATE TABLE sales
(
    sales_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    good_id     integer REFERENCES goods (goods_id),
    sales_time  timestamp with time zone DEFAULT now(),
    sales_qty   integer CHECK (sales_qty > 0)
);

-- заполнение таблицы продажи
INSERT INTO sales (good_id, sales_qty) VALUES (1, 10), (1, 1), (1, 120), (2, 1);

-- отчет: сумма продаж по каждому товару
SELECT G.good_name, sum(G.good_price * S.sales_qty)
FROM goods G
INNER JOIN sales S ON S.good_id = G.goods_id
GROUP BY G.good_name;

-- с увеличением объёма данных отчет стал создаваться медленно
-- Принято решение денормализовать БД, создать таблицу
CREATE TABLE good_sum_mart
(
	good_name   varchar(63) NOT NULL,
	sum_sale	numeric(16, 2)NOT NULL
);

-- Функция для для триггера для добавления/обновления/удаления суммы
CREATE OR REPLACE FUNCTION sales_mart_update()
RETURNS trigger AS $$
DECLARE
    old_sum numeric(16,2);
    new_sum numeric(16,2);
    old_name text;
    new_name text;
BEGIN
    -- имя и сумма для OLD (если есть)
    IF TG_OP IN ('UPDATE','DELETE') THEN
        SELECT good_name, good_price * OLD.sales_qty
        INTO old_name, old_sum
        FROM goods WHERE goods_id = OLD.good_id;
    END IF;

    -- имя и сумма для NEW (если есть)
    IF TG_OP IN ('UPDATE','INSERT') THEN
        SELECT good_name, good_price * NEW.sales_qty
        INTO new_name, new_sum
        FROM goods WHERE goods_id = NEW.good_id;
    END IF;

    -- Уменьшаем старую сумму
    IF old_name IS NOT NULL THEN
        UPDATE good_sum_mart
        SET sum_sale = sum_sale - old_sum
        WHERE good_name = old_name;
    END IF;

    -- Добавляем новую сумму
    IF new_name IS NOT NULL THEN
        INSERT INTO good_sum_mart (good_name, sum_sale)
        VALUES (new_name, new_sum)
        ON CONFLICT (good_name)
        DO UPDATE SET sum_sale = good_sum_mart.sum_sale + EXCLUDED.sum_sale;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Триггер
CREATE TRIGGER trg_sales_mart
AFTER INSERT OR UPDATE OR DELETE ON sales
FOR EACH ROW
EXECUTE FUNCTION sales_mart_update();

-- Заполняем данные в новую таблицу
TRUNCATE good_sum_mart;

INSERT INTO good_sum_mart (good_name, sum_sale)
SELECT g.good_name, SUM(g.good_price * s.sales_qty)
FROM goods g
LEFT JOIN sales s ON s.good_id = g.goods_id
GROUP BY g.good_name;

-- Выборка новой таблицы
SELECT * FROM good_sum_mart ORDER BY good_name;

-- Изменение цены
UPDATE goods
SET good_price = 9999.99
WHERE goods_id = 1;

-- Повторные выборки из витрины и отчёта
SELECT * FROM good_sum_mart ORDER BY good_name;

SELECT G.good_name, sum(G.good_price * S.sales_qty)
FROM goods G
INNER JOIN sales S ON S.good_id = G.goods_id
GROUP BY G.good_name;

-- Добавление нового уникального индекса
CREATE UNIQUE INDEX good_sum_mart_unq ON good_sum_mart (good_name);