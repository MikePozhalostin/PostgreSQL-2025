BEGIN; or START TRANSACTION; - Создать транзакцию

BEGIN TRANSACTION ISOLATION LEVEL <isolation_level>; - Создать транзакцию с уровнем изоляции, REPEATABLE READ, READ COMMITTED, SERIALIZABLE

COMMIT; - зафиксировать изменения

ROLLBACK; - откатить изменения