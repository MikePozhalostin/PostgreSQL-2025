**Реализация проекта: "Кластер Патрони"**

1. Установил etcd на трёх машинах. Настроил и запустил кластер;
![etcd-cluster](images/cluster-etcd.png)\
![etcd-cluster](images/cluster-status.png)
2. Установил Postgres на трёх машинах;
Добавил пользователя replicator и настройки на первую машину
![postgres1](images/postgres-first.png)
Добавил пользователя replicator и настройки на вторую машину
![postgres2](images/postgres-second.png)
Добавил пользователя replicator и настройки на третью машину
![postgres3](images/postgres-third.png)
3. Установил Patroni на трёх машинах;
![patroni1](images/patroni-first.png)
![patroni2](images/patroni-first.png)
![patroni3](images/patroni-first.png)
4. Выполнил настройку patroni.yaml на первой машине с bootstrap. И настройку службы. Затем выполнил настройку patroni на второй и третьей ноде без секции bootstrap. После нескольких перехапусков кластер заработал. Причём, если выполнить рестарт ноде лидере, то лидер меняется.
![cluster](images/cluster-patroni.png)