**Выполнение домашнего задания: "Бэкапы"**

1. Создал VM и запустил Postgres 17;
2. Создал базу данных bkp, в ней создал таблицу student, заполнил данными;
![func](images/bkp_db.png)
3. Создал папку для бэкапов по пути `/var/lib/postgresql/backups`;
![folder](images/folder.png)
4. Создал копию таблицы student без данных;
![copy_table](images/copy_table.png)
5. Восстановил новил данные;
![copy_table](images/logic_back.png)
6. Создал backup с помощью pg_dump двух таблиц командой `pg_dump \
  -Fc \
  -d bkp \
  -n public \
  -t student \
  -t student_copy \
  -f /var/lib/postgresql/backups/two_tables.dump`;
7. Создал новую базу данных для восстановления `createdb restore_hw`;
8. Восстановил только вторую таблицу с помощью pg_restore `pg_restore \
  -d restore_hw \
  -n public \
  -t student_copy \
  /var/lib/postgresql/backups/two_tables.dump`;
![com](images/commands.png)
![second](images/second_back.png)

Прилагаю sql скрипт, который выполнял, в Backup.sql;
