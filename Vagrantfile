# Устанавливаем переменной значение текущей директории расположения Vagrantfile
current_dir = File.join(File.dirname(__FILE__))

# Подключаем yaml
require 'yaml'
#Проверяем условие существования двух yaml файлов конфигураций. Если они существуют то подгружаем их в модули configvms и configglobal
if File.file?("#{current_dir}/config/vagrant/vagrant-config-vms.yaml") && File.file?("#{current_dir}/config/vagrant/vagrant-config-global.yaml")
  configvms     = YAML.load_file("#{current_dir}/config/vagrant/vagrant-config-vms.yaml")
  configglobal  = YAML.load_file("#{current_dir}/config/vagrant/vagrant-config-global.yaml")
else
  #если их нет, то выдаем сообщение об отсутствии и vagrant up не сработает
  raise "Конфигурационный файл/ы отсутствуе/ют"
end

Vagrant.configure("#{configglobal["GLOBAL"]["api_version"]}") do |config|
  # Проходим по элементам массива из yaml файла:
  #   глобальная инициализация будет выполняться сначала для каждой из виртуальных машин, а затем будет инициализация 
  #   с ограниченной областью действия. Поместив контроллер в конец списка, он будет последним, для которого выполняется 
  #   инициализация. Вы можете упорядочить загрузку, изменив порядок из списка и создав дополнительные условия.
  #создаем цикл для установки нужных нам машин
  configvms["VMs"].each do |configvms|
    #проверяется условие нужно ли устанавливать виртуальную машину в соответствии со значением переменной в файле vagrant-config-vms.yaml
    if configvms["setup"] == true
      #если значение переменной true значит устанавливаем машину с именем, заданным в файле vagrant-config-vms.yaml
      config.vm.define configvms["name"] do |vm|
        #проверяем условие если переменная из vagrant-config-global.yaml равна true то на всех виртуальных машинах будет использоваться
        #только 1 образ системы. Если необходимо для каждой ВМ использовать свой образ, переопределить переменную как false
        #и в настройках каждой из ВМ указать желаемый образ.
        if configglobal["GLOBAL"]["box_usage"] == true
          #задаем образ машине и версию из vagrant-config-global.yaml
          vm.vm.box = configglobal["GLOBAL"]["box"]
          #vm.vm.box_version = configglobal["GLOBAL"]["box_version"]
        else
          #если переменная false то задаем образ из vagrant-config-vms.yaml
          vm.vm.box = configvms["box"]
          #vm.vm.box_version = configvms["box_version"]
        end

        # ТРИГГЕРЫ:
        #чистим установленную машину, запуская скрипт у нас в репозитории.
        vm.trigger.after :up do |trigger|
          trigger.name = "\e[34m clean VM #{configvms["name"]} after vagrant up\e[0m"
          trigger.info = "\e[34m  \e[0m"
          trigger.run_remote  = {path: "#{current_dir}/config/vagrant/provision/vagrant-up-after.sh"}
        end
        
        # РАСШИРЕННАЯ КОНФИГУРАЦИЯ:enp3s0
        #   Провайдер(англ. Provider) представляет собой программное обеспечение для создания и управления виртуальными машинами, используемыми в Vagrant. 
        #   Основыными провайдерами являются Virtualbox и VMware.
        #проверяем условие если в файле vagrant-config-global.yaml у переменной значение virtualbox, то конфигурим виртуалку
        if configglobal["GLOBAL"]["vagrant_provider"] == "virtualbox"
          #если в файле vagrant-config-vms.yaml есть значение переменной memory для соответствующей виртуальной машины,
          #то берем это значение. В противном случаем берем значение 1024
          memory = configvms["memory"]  ? configvms["memory"]  : 1024;
          #то же самое с конфигурацией процессора
          cpu = configvms["cpu"]  ? configvms["cpu"]  : 1;
          #присвоение имени машины
          name = configvms["name"];
          vm.vm.provider :virtualbox do |vb|
            vb.customize [
              "modifyvm", :id,
              "--memory", memory.to_s,
              "--cpus", cpu.to_s,
              "--name", name
            ]
          end
        #задаем шаблон условий если вдруг поменяем значение vagrant_provider в vagrant-config-global.yaml
        elsif configglobal["vagrant_provider"] == "vmware_fusion"
        elsif configglobal["vagrant_provider"] == "docker"
        elsif configglobal["vagrant_provider"] == "hyperv"
        elsif configglobal["vagrant_provider"] == "parallels"
        end
        
        # НАСТРОЙКА SSH:
        #   В более ранних версиях Vagrant для подключения к виртуальной машине использовался ключ ~/.vagrant.d/insecure_private_key. 
        #   Но теперь Vagrant выдает предупреждение, что обнаружен небезопасный ключ и заменяет его:
        #   Vagrant insecure key detected. Vagrant will automatically replace
        #   this with a newly generated keypair for better security.
        #   Этот ключ расположен в где-то в недрах директрории .vagrant (создается после первого запуска vagrant up). Посмотреть, какой ключ 
        #   будет использован, можно с помощью команды: vagrant ssh-config
        #   Можно отменить создание ssh-ключа, если определить переменную в vagrant-config-vms.yaml с настройками insert_key = false
        # vm.ssh.username   = configvms["username"]
        # vm.ssh.password   = configvms["password"]
        # vm.ssh.keys_only  = configvms["keys_only"]
        # vm.ssh.insert_key = configvms["insert_key"]         
        
        # КОНФИГУРАЦИЯ СЕТИ:
               #   ЧАСТНАЯ СЕТЬ (Private network):
        #     С частной сетью понятно - мы делаем собственную сеть LAN, которая будет состоять из виртуальных машин. Для доступа к такой сети из хоста нужна 
        #     пробрасывать порт через Vagrantfile (или через Vbox, но через vagrant удобнее). А для доступа из реальной сети, то есть, например из другой 
        #     физической машины, мы должны будем стучаться на IP хоста. Это удобно, если создавать виртуалку для «поиграться» или если планируется использовать 
        #     виртуалку внутри сети и за NAT (например, она получит адрес от DHCP другой виртуалки, которая будет выполнять роль шлюза). IP можно не указывать, можно сделать так:
        #     vm.vm.network "private_network", type: "dhcp"
        #     и адрес назначится автоматически.
        #   ПЕРЕНАПРАВЛЕНИЕ ПОРТОВ:
        #     настройка "forwarded_port" позволит нам открыть порт прослушивания в хост- и гостевой операционных системах.
        #     Хост- операционная система пересылает все полученные пакеты на порт, который мы указываем для гостевой операционной системы.
        #     Эта настройка применяется для каждой из виртуальных машин.
        #     Параметр "auto_correct" означает, что если у вас где-то есть конфликт портов (пробросили на уже занятый порт), то vagrant это дело увидит и сам
        #     исправит. Автоматически эта опция включена только для 22 порта, для портов, которые вы задаёте вручную, нужно указать эту опцию.
        #     Никогда не назначайте проброс портов на стандартные! (например, 22 на 22) Это чревато проблемами в хост- операционной системе.
        #     По-умолчанию проброс идёт ТСР протокола. Для того, чтоб проборосить UDP порт, это нужно явно указать:
        #     vm.vm.network "forwarded_port", guest: 35555, host: 12003, protocol: "udp"
        #     Вообще говоря, перенаправления портов обычно бывает достаточно. Но для особых нужд вам может понадобиться полностью «настоящая» виртуальная машина,
        #     к которой можно стабильно обращаться с хост-машины и к другим ресурсам в локальной сети. Такое требование фактически может быть решено путем
        #     настройки нескольких сетевых карт, например, одна настроена в режиме частной сети, а другая - в режиме общедоступной сети.
        #     Vagrant может поддерживать сетевые модели виртуального бокса NAT, Bridge и Hostonly через файлы конфигурации.
        # проверяем условие если переменная существует со значением то конфигурим сетевую карту с адресом в частной сети
        if configvms["ip_private"]
          vm.vm.network "private_network", ip: configvms["ip_private"]
          #пробрасываем порты в соответствии со значениями переменных port_guest и port_host в vagrant-config-vms.yaml
          vm.vm.network "forwarded_port", guest: configvms["port_guest"], host: configvms["port_host"], auto_correct: true
        end
        #   ПУБЛИЧНАЯ СЕТЬ (Public network):
        #     Публичная сеть означает, что виртуальная машина представлена ​​как хост в локальной сети, т.е. так, как будто появился новый сервер со своим адресом и именем.
        #     С публичной сетью нет необходимости пробрасывать порты - всё доступно по адресу виртуалки. Для всех машин в этой же подсети.
        #     Однако тут надо быть осторожным, так как это может создать некоторые проблемы с DNS и\или DHCP на основном шлюзе.
        #     Если не задать адрес, то он будет задан DHCP-сервером в реальной подсети. По факту, публичная сеть использует bridge-соединение с WAN-адаптером 
        #     хоста. Если у вас два физических адаптера (две сетевых карты, например проводная и беспроводная), то необходимо указать, какой использовать.
        # проверяем условие если есть переменные ip_public и ip_bridge в vagrant-config-vms.yaml у соответствующей машины, то создаем публичную сеть
        if configvms["ip_public"] && configvms["ip_bridge"]
          vm.vm.network :public_network, ip: configvms["ip_public"], bridge: configvms["ip_bridge"]
        end
        
        # СИНХРОНИЗАЦИЯ ФАЙЛОВ ПРОЕКТА:
        #     Хорошей практикой является не копирование файлов проекта в виртуальную машину, а совместное использование файлов между хостом и 
        #     гостевыми операционными системами, потому что если вы удалите свою виртуальную машину, файлы будут потеряны вместе с ней.
        #     "Из коробки" vagrant синхронизирует каталог хоста с Vagrantfile в директорию /vagrant виртуальной машины.
        #     Если на хостовой машине указывать относительный путь, то корневым будет каталоer 1: nat
        #     Для того, чтоб указать дополнительный каталоги для синхронизации, нужно добавить следующую строку в Vagrantfile:
        #     vm.vm.synced_folder "src/", "/var/www/html" 
        #     Первым аргументом является папка на хост-машине, которая будет использоваться совместно с виртуальной машиной.
        #     Второй аргумент – это целевая папка внутри виртуальной машины.
        #     create: true указывает, что если целевой папки внутри виртуальной машины не существует, то необходимо создать ее автоматически.
        #     group: «www-data» и owner: «www-data» указывает владельца и группу общей папки внутри виртуальной машины. 
        #     По умолчанию большинство веб-серверов используют www-данные в качестве владельца, обращающегося к файлам.
        #     Дополнительные опции:
        #       disabled - если указать True, то синхронизация будет отключена. Удобно, если нам не нужна дефолтная синхронизация.
        #       mount_options - дополнительные параметры, которые будут переданы команде mount при монтировании
        #       type - полезная опция, которая позволяет выбрать тип синхронизации. Доступны следующие варианты:
        #         NFS (тип NFS доступен только для Linux хост- ОС);
        #         rsync;
        #         SMB (тип SMB доступен только для Windows хост- ОС);
        #         VirtualBox.
        #     Если эта опция не указана, то vagrant выберет сам подходящую.
        #   Отключаем дефолтные общие папки для каждой из виртуальных машин:
        vm.vm.synced_folder ".", "/vagrant", disabled: true
        vm.vm.synced_folder "./www", "/var/www/html", disabled: true
        #задаем hostname машины, используя переменные name и domain из vagrant-config-vms.yaml
        #переменной domain не существует в vagrant-config-vms.yaml, то она просто проигнорируется
        vm.vm.hostname = configvms["name"]["domain"]
        #задаем свой общие папки в соответствии со значениями document_root и apache_document_root в vagrant-config-vms.yaml
        vm.vm.synced_folder configvms["host_folder"] , configvms["guest_folder"] ,
          create: true, 
          owner: configvms["owner"],
          group: configvms["group"]

        # КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL:
        #   для конкретной виртуальной машины текущего элемента массива при первой инициализации
        # проверяем условие существования файла скрипта, если есть, то выполняем его для соответствующей машины
        if File.file?("#{current_dir}/config/vagrant/provision/provision-#{configvms["name"]}.sh")
          vm.vm.provision "shell", path: "#{current_dir}/config/vagrant/provision/provision-#{configvms["name"]}.sh",
        # и передаем общие переменные окружения в машину. тут можно изменить логику, потому что не каждой машине нужны такие переменные
        # не забываем что мы здесь в цикле и одноименные скрипты будут запускаться для соответствующих машин.
            env: {
              "PHPVERSION"  => "#{configglobal["GLOBAL"]["php_version"]}",
              "DBHOST"      => "#{configvms["mysql_dbhost"]}", 
              "DBNAME"      => "#{configvms["mysql_dbname"]}", 
              "DBUSER"      => "#{configvms["mysql_dbuser"]}", 
              "DBPASSWD"    => "#{configvms["mysql_dbpasswd"]}"
            }
        end
        # проверяем условие если имя машины mysql, то запускаем скрипт создания 3х баз данных (цикл). Параметры баз указаны в vagrant-config-vms.yaml
        if configvms["name"] == "mysql"
          configvms["mysql_database"].each do |configmysql|
            vm.vm.provision "shell", path: "#{current_dir}/config/vagrant/provision/provision-mysql-createdb.sh",
        # также передаем переменные окружения
              env: {
                "DB_ROOT_USER"    => "#{configvms["mysql_dbuser"]}", 
                "DB_ROOT_PASSWD"  => "#{configvms["mysql_dbpasswd"]}",
                "DBNAME"          => "#{configmysql["dbname"]}",
                "DBUSER"          => "#{configmysql["dbuser"]}", 
                "DBPASSWD"        => "#{configmysql["dbpwd"]}"
              }
          end
        end
        # проверяем условие если имя машины dev, то запускаем скрипт создания  2х виртуальных хостов (цикл). Параметры  указаны в vagrant-config-vms.yaml
        if configvms["name"] == "dev"
          configvms["VirtualHost"].each do |virtualhost|
            vm.vm.provision "shell", path: "#{current_dir}/config/vagrant/provision/provision-dev-virtualhost-create.sh",
        # также передаем переменные окружения
              env: {
                "ServerAdmin"   => "#{virtualhost["ServerAdmin"]}",
                "ServerName"    => "#{virtualhost["ServerName"]}",
                "ServerAlias"   => "#{virtualhost["ServerAlias"]}",
                "DocumentRoot"  => "#{virtualhost["DocumentRoot"]}",
              }
          end
        # далее запускаем скрипт регистрации хостов
          vm.vm.provision "shell", path: "#{current_dir}/config/vagrant/provision/provision-dev-virtualhost-register.sh"
        end
          if configvms["name"] == "gitlab-runners"
            vm.vm.provision "shell", path: "#{current_dir}/config/vagrant/provision/provision-gitlab-runners-register.sh",
        # также передаем переменные окружения
              env: {
                "PATH_ANSWERS"  => "#{configvms["path"]}",
                "IMAGE"         => "#{configvms["image"]}",
                "URL"           => "#{configvms["url"]}",
                "TOKEN"         => "#{configvms["token"]}",
              }
          end
        # ДОБАВЛЕНИЕ ПЕРСОНАЛЬНЫХ ПАРАМЕТРОВ ВИРТУАЛЬНЫХ МАШИН ПОСЛЕ ГЛАВНОГО ЦИКЛА ЕСЛИ ТРЕБУЕТСЯ
        if configvms["name"] == "gitlab-runners"
          # ТРИГГЕРЫ:
          #   ...
          # ПРОБРОС ПОРТОВ:
          #   ...
          # СИНХРОНИЗАЦИЯ ФАЙЛОВ ПРОЕКТА:
          #   ...
          # ДОПОЛНИТЕЛЬНАЯ КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL
          # при первой загрузке
          #   ...
          #   при каждой загрузке:
          #   ...
        elsif configvms["name"] == "mysql"
          # ТРИГГЕРЫ:
          vm.trigger.before :halt do |trigger|
            trigger.name = "\e[34m vagrant halt #{configvms["name"]} VM\e[0m"
            trigger.info = "\e[34m Останавливаем MySQL сервер баз данных \e[0m"
            #запускаем скрипт vagrant-halt-mysql-before.sh для бекапа БД
            trigger.run_remote  = {path: "#{current_dir}/config/vagrant/provision/vagrant-halt-mysql-before.sh"}
          end
          # ПРОБРОС ПОРТОВ:
          #   Дополнительно проброс портов для виртуальной машины "MySQL"
          #   Для MySQL стандартный порт 3306, значения берутся из YAML-файла с настройками. 
          #   Если у вас уже используется этот порт, вы можете изменить его.
          #   Для веб-приложений, например для phpmyadmin, значения берутся из YAML-файла с настройками.
          vm.vm.network "forwarded_port", guest: configvms["mysql_guest"], host: configvms["mysql_guest"]
          # СИНХРОНИЗАЦИЯ ФАЙЛОВ ПРОЕКТА:
          #   ...
          # ДОПОЛНИТЕЛЬНАЯ КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL
          # при первой загрузке:
          #   ...      
          # при каждой загрузке:
          #   ...
        end                     
      end
    end
  end
  
  # КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL:
  #   для каждой из вирутальных машин при первой инициализации запустить скрипт provision.sh
  config.vm.provision "shell", path: "#{current_dir}/config/vagrant/provision/provision.sh",
    env: {
    }
end
