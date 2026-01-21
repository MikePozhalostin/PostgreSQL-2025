# Реализация проекта: "Создание высоконагруженного отказоустойчивого кластера PostgreSQL на базе Patroni"

## Введение
Были подняты три виртуальные машины для последующей установки на них etcd, postgres и patroni:
![vms](images/vms.png)
Ips:
1: 192.168.1.155
2: 192.168.1.185
3: 192.168.1.152

## Установка ETCD и создание ETCD-кластера

### Выполнение установки ETCD на первой машине 192.168.1.155

1.Установка etcd:
```bash
sudo apt -y install etcd-server
sudo apt -y install etcd-client
```

2.Остановка etcd:
```bash
sudo systemctl stop etcd
sudo systemctl disable etcd
```

3.Удаление дефолтной настройки etcd:
```bash
sudo rm -rf /var/lib/etcd/default
```

4.Настройка файла конфигурации
```bash
sudo nano /etc/default/etcd

ETCD_NAME="etcd-Name-1"
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.155:2379,http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.155:2379"
ETCD_LISTEN_PEER_URLS="http://192.168.1.155:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.155:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd_Name_Claster"
ETCD_INITIAL_CLUSTER="etcd-Name-1=http://192.168.1.155:2380,etcd-Name-2=http://192.168.1.185:2380,etcd-Name-3=http://192.168.1.152:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_ELECTION_TIMEOUT="10000"
ETCD_HEARTBEAT_INTERVAL="2000"
ETCD_INITIAL_ELECTION_TICK_ADVANCE="false"
ETCD_ENABLE_V2="true"
```

5.Инициализация службы для запуска ETCD
```bash
sudo nano /etc/systemd/system/etcd.service

[Unit]
Description=etcd - highly-available key value store
Documentation=https://github.com/etcd-io/etcd
After=network.target
Wants=network-online.target

[Service]
Type=notify
User=etcd
Group=etcd
EnvironmentFile=-/etc/default/etcd
ExecStart=/usr/bin/etcd
Restart=on-failure
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

6.Настройка автозапуска etcd:
```bash
sudo systemctl daemon-reload

sudo systemctl enable etcd

sudo systemctl start etcd 
```

### Выполнение установки ETCD на второй машине 192.168.1.185

Выполнены пункты 1, 2, 3, 5, 6 как на первой машине.

4.Настройка файла конфигурации
```bash
sudo nano /etc/default/etcd

ETCD_NAME="etcd-Name-2"
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.185:2379,http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.185:2379"
ETCD_LISTEN_PEER_URLS="http://192.168.1.185:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.185:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd_Name_Claster"
ETCD_INITIAL_CLUSTER="etcd-Name-1=http://192.168.1.155:2380,etcd-Name-2=http://192.168.1.185:2380,etcd-Name-3=http://192.168.1.152:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_ELECTION_TIMEOUT="10000"
ETCD_HEARTBEAT_INTERVAL="2000"
ETCD_INITIAL_ELECTION_TICK_ADVANCE="false"
ETCD_ENABLE_V2="true"
```

### Выполнение установки ETCD на третьей машине 192.168.1.152

Выполнены пункты 1, 2, 3, 5, 6 как на первой и второй машине.

4.Настройка файла конфигурации
```bash
sudo nano /etc/default/etcd

ETCD_NAME="etcd-Name-3"
ETCD_LISTEN_CLIENT_URLS="http://192.168.1.152:2379,http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.152:2379"
ETCD_LISTEN_PEER_URLS="http://192.168.1.152:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.152:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd_Name_Claster"
ETCD_INITIAL_CLUSTER="etcd-Name-1=http://192.168.1.155:2380,etcd-Name-2=http://192.168.1.185:2380,etcd-Name-3=http://192.168.1.152:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_ELECTION_TIMEOUT="10000"
ETCD_HEARTBEAT_INTERVAL="2000"
ETCD_INITIAL_ELECTION_TICK_ADVANCE="false"
ETCD_ENABLE_V2="true"
```

### Кластер ETCD
```bash
sudo etcdctl member list
sudo etcdctl endpoint health --cluster
sudo etcdctl endpoint status --cluster -w table
```
![etcd-cluster](images/cluster-etcd.png)
![etcd-cluster](images/cluster-status.png)
![etcd-cluster](images/etcd-cluster-table.png)

## Настройка postgresql

Действия проводятся на трёх машинах.

1.Установка postgres-17
```bash
sudo apt update
sudo dpkg --configure -a
sudo apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt install postgresql-17 postgresql-client-17
```
2.Создание пользователя *replicator*
```bash
sudo -u postgres psql postgres
create user replicator replication login encrypted password '1';
```
3.Редактирование конфигов postgres
```bash
sudo nano /etc/postgresql/17/main/pg_hba.conf
host all all 0.0.0.0/0 scram-sha-256
host replication replicator 0.0.0.0/0 scram-sha-256

sudo nano /etc/postgresql/17/main/postgresql.conf
listen_addresses = '*'
```
4. Для первой ноды перезапуск postgres
```bash
sudo systemctl restart postgresql
```
5.Для второй и третьей остановка и удаление основных файлов кластера
```bash
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/17/main/*
```

Добавление пользователя replicator и настройки на первую машину
![postgres1](images/postgres-first.png)
Добавление пользователя replicator и настройки на вторую машину
![postgres2](images/postgres-second.png)
Добавление пользователя replicator и настройки на третью машину
![postgres3](images/postgres-third.png)

## Настройка Patroni

1.Установка patroni на трёх машинах
```bash
sudo apt -y install python3 python3-pip python3-dev python3-psycopg2 libpq-dev
sudo pip3 install launchpadlib --break-system-packages
sudo pip3 install --upgrade setuptools --break-system-packages
sudo pip3 install psycopg2 --break-system-packages
sudo pip3 install python-etcd --break-system-packages
sudo apt -y install patroni
sudo systemctl stop patroni
sudo systemctl disable patroni
``` 

2.Настройка конфиг файла на первой машине 192.168.1.155
```bash
sudo nano /etc/patroni.yml

scope: cluster-patroni
namespace: /db/
name: node1

restapi:
  listen: 192.168.1.155:8008
  connect_address: 192.168.1.155:8008

etcd:
  hosts: 192.168.1.155:2379,192.168.1.185:2379,192.168.1.152:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:
        autovacuum_analyze_scale_factor: 0.01

  initdb:
  - encoding: UTF8

  pg_hba:
  - host replication replicator 127.0.0.1/8 scram-sha-256
  - host replication replicator 192.168.1.155/32 scram-sha-256
  - host replication replicator 192.168.1.185/32 scram-sha-256
  - host replication replicator 192.168.1.152/32 scram-sha-256
  - host all all 0.0.0.0/0 scram-sha-256

  users:
    replicator:
      password: "1"
      options:
        - replication

postgresql:
  listen: "127.0.0.1,192.168.1.155:5432"
  connect_address: 192.168.1.155:5432
  data_dir: /var/lib/postgresql/17/main
  bin_dir: /usr/lib/postgresql/17/bin
  authentication:
    replication:
      username: replicator
      password: "1"
    superuser:
      username: postgres
      password: ""

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
  nosync: false
```

3.Настройка конфиг файла второй машине 192.168.1.185
```bash
sudo nano /etc/patroni.yml

scope: cluster-patroni
namespace: /db/
name: node2

restapi:
  listen: 192.168.1.185:8008
  connect_address: 192.168.1.185:8008

etcd:
  hosts: 192.168.1.155:2379,192.168.1.185:2379,192.168.1.152:2379

postgresql:
  listen: "127.0.0.1,192.168.1.185:5432"
  connect_address: 192.168.1.185:5432
  data_dir: /var/lib/postgresql/17/main
  bin_dir: /usr/lib/postgresql/17/bin
  authentication:
    replication:
      username: replicator
      password: "1"
    superuser:
      username: postgres
      password: "postgres"

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
  nosync: false
```

4.Настройка конфиг файла третьей машине 192.168.1.152
```bash
sudo nano /etc/patroni.yml

scope: cluster-patroni
namespace: /db/
name: node3

restapi:
  listen: 192.168.1.152:8008
  connect_address: 192.168.1.152:8008

etcd:
  hosts: 192.168.1.155:2379,192.168.1.185:2379,192.168.1.152:2379

postgresql:
  listen: "127.0.0.1,192.168.1.152:5432"
  connect_address: 192.168.1.152:5432
  data_dir: /var/lib/postgresql/17/main
  bin_dir: /usr/lib/postgresql/17/bin
  authentication:
    replication:
      username: replicator
      password: "1"
    superuser:
      username: postgres
      password: "postgres"

tags:
  nofailover: false
  noloadbalance: false
  clonefrom: false
  nosync: false
```

5.На трёх машинах инициализировал службу
```bash
sudo nano /etc/systemd/system/patroni.service

[Unit]
Description=High availability PostgreSQL Cluster
After=syslog.targetnetwork.target
[Service]
Type=simple:
User=postgres
Group=postgres
ExecStart=/usr/bin/patroni /etc/patroni.yml
KillMode=process
TimeoutSec=30
Restart=no
[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl enable patroni
sudo systemctl start patroni
sudo systemctl status patroni
```

Установка Patroni на трёх машинах;
![patroni1](images/patroni-first.png)
![patroni2](images/patroni-first.png)
![patroni3](images/patroni-first.png)

## Тонкости и проблемы при установке кластера Patroni
1. Мелкие правки в конфигах из презентации;
2. Кластер ETCD после рестарта виртуальных машин не запускался. Связано с недонастройкой конфига службы и поправил конфиг ETCD ETCD_INITIAL_CLUSTER_STATE="existing". После перезапуска стартанул.
![cluster](images/after_restart_vm.png)
3. Выполнил настройку patroni.yaml на первой машине с bootstrap. И настройку службы. Затем выполнил настройку patroni на второй и третьей ноде без секции bootstrap.

## Тестирование работы кластера
Если и выполнить рестарт ноде лидере, то лидер меняется.
![cluster](images/cluster-patroni.png)
Сначала лидер 152. Выполнил на 152 машине. Лидером стал 185
```bash
sudo systemctl status patroni
patronictl -c /etc/patroni.yml list
```

## Установка Prometheus

**Установка на четвёртую машину 192.168.1.174**

1.Установить пакеты:
```bash
sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir /etc/prometheus /var/lib/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz

tar xvf prometheus-2.47.0.linux-amd64.tar.gz

cd prometheus-2.47.0.linux-amd64/

sudo cp prometheus /usr/bin/

sudo cp promtool /usr/bin/

sudo chown prometheus:prometheus /usr/bin/prometheus

sudo chown prometheus:prometheus /usr/bin/promtool
```

2.Настраить конфиг:

```bash
sudo nano /etc/prometheus/prometheus.yml

global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'patroni'
    static_configs:
      - targets:
        - '192.168.1.155:8008'
        - '192.168.1.185:8008'
        - '192.168.1.152:8008'
    metrics_path: '/metrics'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance


  - job_name: 'postgres'
    static_configs:
      - targets:
        - '192.168.1.155:9187'
        - '192.168.1.185:9187'
        - '192.168.1.152:9187'


  - job_name: 'node'
    static_configs:
      - targets:
        - '192.168.1.155:9100'
        - '192.168.1.185:9100'
        - '192.168.1.152:9100'
        - '192.168.1.174:9100'

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

3.Настроить службу:

```bash
sudo nano /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090
Restart=always

[Install]
WantedBy=multi-user.target
```

5.Запуcтить prometheus:
```bash
sudo systemctl daemon-reload

sudo systemctl enable prometheus

sudo systemctl start prometheus

sudo systemctl status prometheus
```

## Установка Node-Exporter

### Установка осуществляется на все машины

1.Установка:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

tar xvf node_exporter-*.tar.gz

cd node_exporter-1.7.0.linux-amd64/

sudo cp node_exporter /usr/bin/

sudo useradd --no-create-home --shell /bin/false node_exporter

sudo chown node_exporter:node_exporter /usr/bin/node_exporter
```

2.Инициализация службы:

```bash
sudo nano /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload

sudo systemctl enable node_exporter

sudo systemctl start node_exporter
```

## Установка Postgres Exporter

### Установка на машины c patroni

```bash
sudo apt install prometheus-postgres-exporter

sudo nano /etc/default/prometheus-postgres-exporter

DATA_SOURCE_NAME='postgresql://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable'

sudo systemctl enable prometheus-postgres-exporter

sudo systemctl start prometheus-postgres-exporter
```
