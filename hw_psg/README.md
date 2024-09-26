В результате работы плейбука:  
Создался юзер
```
postgres=# \du                                                                         
                                    List of roles                                      
  Role name  |                         Attributes                         | Member of  
-------------+------------------------------------------------------------+----------- 
 barman      | Superuser                                                  | {}         
 postgres    | Superuser, Create role, Create DB, Replication, Bypass RLS | {}         
 replication | Replication                                                | {}         
```

Прокинулся postgresql.conf:  
```
vagrant@node1:~$ sudo tail -n 30 /etc/postgresql/14/main/postgresql.conf
max_connections = 100
log_directory = 'log'
log_filename = 'postgresql-%a.log'
log_rotation_age = 1d
log_rotation_size = 0
log_truncate_on_rotation = on
max_wal_size = 1GB
min_wal_size = 80MB
log_line_prefix = '%m [%p] '
#Указываем часовой пояс для Москвы
log_timezone = 'UTC+3'
timezone = 'UTC+3'
datestyle = 'iso, mdy'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'
#можно или нет подключаться к postgresql для выполнения запросов в процессе восстановления;
hot_standby = on
#Включаем репликацию
wal_level = replica
#Количество планируемых слейвов
max_wal_senders = 3
#Максимальное количество слотов репликации
max_replication_slots = 3
#будет ли сервер slave сообщать мастеру о запросах, которые он выполняет.
hot_standby_feedback = on
#Включаем использование зашифрованных паролей
password_encryption = scram-sha-256
```  
А также pg_hba.conf
```
vagrant@node1:~$ sudo tail -n 30 /etc/postgresql/14/main/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all                  all                                                peer
# IPv4 local connections:
host    all                  all             127.0.0.1/32              scram-sha-256
# IPv6 local connections:
host    all                  all             ::1/128                       scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication      all                                                peer
host    replication     all             127.0.0.1/32               scram-sha-256
host    replication     all             ::1/128                        scram-sha-256
host    replication replication    192.168.57.11/32        scram-sha-256
host    replication replication    192.168.57.12/32        scram-sha-256
host    all             barman          192.168.57.13/32        scram-sha-256
host    replication     barman          192.168.57.13/32        scram-sha-256
```
Также настроена репликация. Вывод команды "select * from pg_stat_replication;" следующий
```
 pid  | usesysid |   usename   |  application_name  |  client_addr  | client_hostname | client_port |         backend_start         | backend_xmin |   state   | sent_lsn  | write_lsn | flush_lsn | replay_lsn |    write_lag    |    flush_lag    |   replay_lag    | sync_priority | sync_state |          reply_time
------+----------+-------------+--------------------+---------------+-----------------+-------------+-------------------------------+--------------+-----------+-----------+-----------+-----------+------------+-----------------+-----------------+-----------------+---------------+------------+-------------------------------
 9595 |    16384 | replication | 14/main            | 192.168.57.12 |                 |       33028 | 2024-09-26 14:45:13.786435-03 |          737 | streaming | 0/7000148 | 0/7000148 | 0/7000148 | 0/7000148  |                 |                 |                 |             0 | async      | 2024-09-26 15:20:23.315476-03
 9598 |    16385 | barman      | barman_receive_wal | 192.168.57.13 |                 |       47646 | 2024-09-26 14:45:14.59818-03  |              | streaming | 0/7000148 | 0/7000148 | 0/7000000 |            | 00:00:05.388702 | 00:35:12.351124 | 00:35:12.351124 |             0 | async      | 2024-09-26 15:20:26.970512-03
(2 rows)
```
Ещё способ проверить репликацию
```
vagrant@node1:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.13 (Ubuntu 14.13-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# select * from pg_stat_replication;
postgres=# CREATE DATABASE bimbim_bambam;
CREATE DATABASE
postgres=# \l
                                    List of databases
     Name      |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
---------------+----------+----------+-------------+-------------+-----------------------
 bimbim_bambam | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 otus          | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
(5 rows)

postgres=# select * from pg_stat_replication;
postgres=# ^C
postgres=#                                                                                                                                                                                                       \q
vagrant@node1:~$                                                                                                                                                                                                 logout
root@ubuntich:/home/user/hw/hw_psg/ansible# vagrant ssh node2
Last login: Thu Sep 26 17:45:04 2024 from 192.168.57.1
vagrant@node2:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.13 (Ubuntu 14.13-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                                    List of databases
     Name      |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
---------------+----------+----------+-------------+-------------+-----------------------
 bimbim_bambam | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 otus          | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
(5 rows)
```
Затем идёт настройка barman. Вот результат:
```
vagrant@barman:~$ psql -h 192.168.57.11 -U barman -d postgres
Password for user barman:
psql (14.13 (Ubuntu 14.13-0ubuntu0.22.04.1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=#                                  
```
```
vagrant@barman:~$ psql -h 192.168.57.11 -U barman -c "IDENTIFY_SYSTEM" replication=1
Password for user barman:
      systemid       | timeline |  xlogpos  | dbname
---------------------+----------+-----------+--------
 7419006030690678836 |        1 | 0/7000AF0 |
(1 row)
```
```
barman@barman:~$ barman check node1
Server node1:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK                                                                                                                                                                                                    replication slot: OK
        directories: OK                                                                                                                                                                                                  retention policy settings: OK
        backup maximum age: FAILED (interval provided: 4 days, latest backup age: No available backups)                                                                                                                  backup minimum size: OK (0 B)
        wal maximum age: OK (no last_wal_maximum_age provided)                                                                                                                                                           wal size: OK (0 B)
        compression settings: OK                                                                                                                                                                                         failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: FAILED (have 0 backups, expected at least 1)                                                                                                                                    pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
```
Удалив некоторые бд
```
postgres=# drop database bimbim_bambam;
DROP DATABASE                                                                                                                                                                                                    postgres=# drop database otus;
DROP DATABASE
postgres=# ^C
postgres=#
\q
vagrant@node1:~$
logout
root@ubuntich:/home/user/hw/hw_psg/ansible# vagrant ssh barman
Last login: Thu Sep 26 18:25:36 2024 from 10.0.2.2
vagrant@barman:~$
logout
root@ubuntich:/home/user/hw/hw_psg/ansible# vagrant ssh node1
Last login: Thu Sep 26 18:30:54 2024 from 10.0.2.2
vagrant@node1:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.13 (Ubuntu 14.13-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(3 rows)
```
Делаем восстановление
```
barman@barman:~$ barman recover node1 20240926T182950 /var/lib/postgresql/14/main/ --remote-ssh-comman "ssh postgres@192.168.57.11"
The authenticity of host '192.168.57.11 (192.168.57.11)' can't be established.
ED25519 key fingerprint is SHA256:tdVre3jC/W/7c2kW7udwXura2pFJZAjMSdVMd0vvn1w.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Starting remote restore for server node1 using backup 20240926T182950
Destination directory: /var/lib/postgresql/14/main/
Remote command: ssh postgres@192.168.57.11
Copying the base backup.
Copying required WAL segments.
Generating archive status files
Identify dangerous settings in destination directory.

WARNING
The following configuration files have not been saved during backup, hence they have not been restored.
You need to manually restore them in order to start the recovered PostgreSQL instance:

    postgresql.conf
    pg_hba.conf
    pg_ident.conf

Recovery completed (start time: 2024-09-26 18:33:59.199702, elapsed time: 8 seconds)

Your PostgreSQL server has been successfully prepared for recovery!
barman@barman:~$
```
И зайдя снова на мастер удаленные базы вернулись
```
vagrant@node1:~$ sudo systemctl restart postgresql
vagrant@node1:~$ sudo -u postgres psql
could not change directory to "/home/vagrant": Permission denied
psql (14.13 (Ubuntu 14.13-0ubuntu0.22.04.1))
Type "help" for help.

postgres=# \l
                                    List of databases
     Name      |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges                                                                                                                           ---------------+----------+----------+-------------+-------------+-----------------------
 bimbim_bambam | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 otus          | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
(5 rows)
```

