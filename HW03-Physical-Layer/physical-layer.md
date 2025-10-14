**Выполнение домашнего задания по установке и настройке postgres.**

1. Создал виртуальную машину с Ubuntu 22.04 LTS в VirtualBox;
2. Поставил Postgres 17;
3. Кластер запущен
!(/images/claster.png)
4. Выполнил команду `sudo -u postgres psql postgres` и вошёл под user postges;
5. Создал тестовую таблицу с помощью команды `create table test(c1 text);` и добавил запись в таблицу с помощью команды `insert into test values('1');`;
!(/images/create_test_table.png)
6. Остановил кластер;
7. Создал жёсткий диск, приаттачил к машине;
!(/images/attach.png)
8. Проинициализировал диск и примонтировал файловую систему;
!(/images/initialize_disk.png)
!(/images/file_system.png)
9. После перезапуска диск примонтирован;
!(/images/after_reboot.png)
10. Перенёс /var/lib/postgres/17 в /mnt/data;
11. Выполнение команды `sudo -u postgres pg_ctlcluster 17 main start;` **завершилось ошибкой**. /var/lib/postgres/17/main does not exist, потому что директория с данными была перенесена;
!(/images/not_exist_main.png)
12. Поменял в конфиге /etc/postgresql/17/main/postgres.conf значение **data_directory** на /mnt/data/17/main
!(/images/change_conf.png)
13. После сохранения кластер стартанул, потому что указали актуальную директорию данных;
!(/images/claster_status_after_move.png)
14. При выполении select данные отобразились;
!(/images/data_after_move.png)
15. (*) Запустил вторую VM, установил на неё Postgres, не добавлял информацию по таблице test. Перемонтировал внешний диск, который был на первой машине. Поправил конфиг postrges на второй машине, чтобы data_directory указывала на mnt/data. Запустил кластер и выполнил select от пользователя postges. Данные с созданной таблицей test и одной записью с первой машины появились во второй;