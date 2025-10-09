# Transactions
BEGIN; or START TRANSACTION; - Создать транзакцию

BEGIN TRANSACTION ISOLATION LEVEL <isolation_level>; - Создать транзакцию с уровнем изоляции, REPEATABLE READ, READ COMMITTED, SERIALIZABLE

set transaction isolation level repeatable read; - установить уровень изоляции транзакции, после начала (Begin, start transaction)

show transaction isolation level; - показать уровень изоляции транзакции

COMMIT; - зафиксировать изменения

ROLLBACK; - откатить изменения