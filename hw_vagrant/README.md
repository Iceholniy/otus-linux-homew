Для начала в ~/.bashrc в самый низ в переменные http/https_proxy был указан адрес хоста с вагрантом, поскольку выход в сеть на машине через прокси с логином и паролем, которые раздаются через службу cntlm на хосте, которая слушает по 3128 порту запросы
Затем на виртуальной машине был скачан публичный ключ elrepo

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

Далее был скачан репозиторий elrepo 

yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

И установлены пакеты ядра mainline stable
yum --enablerepo=elrepo-kernel install kernel-ml

На всякий случай вручную поменял ядро при запуске

grub2-mkconfig -o /boot/grub2/grub.cfg

grub2-set-default 0

и после перезагрузки следующий результат
[root@kernel-update ~]# uname -r

6.7.9-1.el8.elrepo.x86_64
