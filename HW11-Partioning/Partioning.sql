-- Минимальные и максимальные значения времени посадки
SELECT Max(boarding_time) as max, Min(boarding_time) as min FROM bookings.boarding_passes;

-- Создание головной таблицы для секционирования
CREATE TABLE boarding_passes_range (
       ticket_no text COLLATE pg_catalog."default" NOT NULL,
    flight_id integer NOT NULL,
    seat_no text COLLATE pg_catalog."default" NOT NULL,
    boarding_no integer,
    boarding_time timestamp with time zone NOT NULL,
    CONSTRAINT boarding_passes_pkey_boarding_time PRIMARY KEY (ticket_no, flight_id, boarding_time),
    CONSTRAINT boarding_passes_flight_id_boarding_no_key_boarding_time UNIQUE (flight_id, boarding_no, boarding_time),
    CONSTRAINT boarding_passes_flight_id_seat_no_key_boarding_time UNIQUE (flight_id, seat_no, boarding_time),
    CONSTRAINT boarding_passes_ticket_no_flight_id_fkey FOREIGN KEY (ticket_no, flight_id)
        REFERENCES bookings.segments (ticket_no, flight_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
   ) PARTITION BY RANGE(boarding_time);

-- Создание секций по месячно
   CREATE TABLE boarding_passes_range_202510 PARTITION OF boarding_passes_range 
       FOR VALUES FROM ('2025-10-01'::timestamptz) TO ('2025-11-01'::timestamptz);
   CREATE TABLE boarding_passes_range_202511 PARTITION OF boarding_passes_range 
       FOR VALUES FROM ('2025-11-01'::timestamptz) TO ('2025-12-01'::timestamptz);
	CREATE TABLE boarding_passes_range_202512 PARTITION OF boarding_passes_range 
       FOR VALUES FROM ('2025-12-01'::timestamptz) TO ('2026-01-01'::timestamptz);

-- Перенос записей из оригинальной таблицы в таблицу с секциями
INSERT INTO boarding_passes_range SELECT * FROM boarding_passes where boarding_time is not null;

-- Выполнение выборки без индексов на таблицах
explain analyze select * from boarding_passes where boarding_time > '2025-11-30';

explain analyze select * from boarding_passes_range where boarding_time > '2025-11-30';

-- Создание индекса на оригинальной таблице
create index boarding_passes_data_index_origin on boarding_passes(boarding_time);
-- Создание индекса на таблицу с секциями
create index boarding_passes_data_index_range on boarding_passes_range(boarding_time);

-- Вставка
INSERT INTO bookings.boarding_passes_range(
	ticket_no, flight_id, seat_no, boarding_no, boarding_time)
	VALUES ('0005432000000', 108, '39F', 343, '2025-10-02 17:35:05.617326+03');

-- Обновление
UPDATE bookings.boarding_passes_range
	SET seat_no=353
	WHERE ticket_no = '0005432000000' and boarding_time = '2025-10-02 17:35:05.617326+03';

-- Удаление
DELETE FROM bookings.boarding_passes_range
	WHERE ticket_no = '0005432000000' and boarding_time = '2025-10-02 17:35:05.617326+03';