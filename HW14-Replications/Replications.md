**Выполнение домашнего задания: "Репликация"**

1. Запустил первый кластер на порте 5432 Postgres 17. Выставил wal_level logical. Создал БД otus, создал таблицы test и test2. Сделал публикацию таблицы test;
![pub_1](images/pub_for_test.png)
2. Создал новый кластер Secondary на порте 5433 Postgres 17;
![sec](images/secondary_cluster.png)
3. На Secondary выставил wal_level logical. Создал БД otus, создал таблицы test и test2. Сделал публикацию таблицы test2;
![sec](images/sec_tables.png)
![sec](images/sec_pub_test2.png)
4. Сделал подписку на первом кластере таблицы test2 на таблицу test во втором кластере;
![first_sub](images/sub_first.png)
5. Сделал подписку на втором кластере таблицы test2 на таблицу test во первом кластере;
![sec_sub](images/sub_second.png)
6. Проверил публикацию test из первого кластера в test второго. Всё работает, данные при вставке в первом появидись во втором;
![sec_sub](images/check_first_pub.png)
![sec_sub](images/check_sub_second.png)
7. Аналогично проверил публикацию test2 во втором кластере и подписку test2 в первом. Всё отработало;
![sec_sub](images/check_pub_sec.png)
![sec_sub](images/check_sub_first.png)
8. По аналогии с пунктом 1, 2 создал третий кластер. Создал базу otus, создал таблицы test и test2. Подписал test на таблицу test из первого кластера, подписал test2 на таблицу из второго кластера;