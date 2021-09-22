### Dockerized PHP7.4.23-FPM

![Logo](./assets/logo.png)

### Status
<img alt="Image Size" src="https://img.shields.io/docker/image-size/eduardsaryan/lemp-php5.6-fpm" style="max-width:100%;"> <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/eduardsaryan/lemp-php5.6-fpm" style="max-width:100%;"> <img alt="Build Status" src="https://img.shields.io/docker/cloud/build/eduardsaryan/lemp-php5.6-fpm" style="max-width:100%;"> <img alt="Licenses" src="https://img.shields.io/badge/License-GPLv3-blue.svg" style="max-width:100%;">

### Table of contents
* [Prerequisites](#Prerequisites)
* [Project Tree](#Project-Tree)
* [Backup Folder](#Backup-Folder)
* [Config Folder](#Config-Folder)
* [Rename](#Rename)
* [Deployment](#Deployment)

The use of PHP-7.4.23 integrated Nginx-1.18 is based on  [dockerized-lemp-php5.6-fpm](https://github.com/eduardsaryan/dockerized-lemp-php5.6-fpm) modification

### Prerequisites
*	[Connect to the Internet](http://www.brandx.net/support/dsl/quickstart/dsl-quickstart.html)
*	[Docker](https://www.docker.com/)
*	[Docker Compose](https://docs.docker.com/compose/install/)
*	[php artisan key:generate](https://github.com/laravel/framework/issues/20719)

### Project Tree
```less
├── .env.db
├── .env.web
├── docker-compose.yml
├── Dockerfile
├── backup
│   ├── db_backup.sh
│   ├── db_restore.sh
│   ├── web_backup.sh
│   └── web_restore.sh
├── conf
|   ├── fpm.conf
|   ├── php.ini
|   ├── supervisord.conf
│   └── website.conf
├── docker-compose.yml
├── webapp
|   └── public
|       ├── favicon.ico
|       └── index.php      
└── webinfo
    └── index.php
```

### Backup Folder
| File                        | Description                              |
| :-------------------------- |:---------------------------------------- |
| db_backup.sh                | Small script to backup MySQL database    |      
| db_restore                  | Small script to backup web Folder        |
| web_backup.sh               | Small script to restore MySQL database   |
| web_restore.sh              | Small script to restore web Folder       |

### Config Folder
| File                        | Description                              |
| :-------------------------- |:------------------------------------------------------------------------------------ |
| fpm.conf                    | Custom PHP-FPM config                                                                |
| php.ini                     | For additional configurations of PHP, еdit this file before deploying the container. |  
| supervisord.conf            | supervisord.conf basic config                                                        |
| website.conf                | Nginx basic config file.                                                             |

### Rename
It is highly advised to change all names.

-----

### Deployment
Clone repo to your server. I suggest using ```/opt``` directory
```less
sudo git clone https://github.com/jameshue/exercise-php-nginx-mysql.git
```

Put your WEB-Application into the ```webapp``` folder. <br>
Navigate to the project folder and start containers.

```less
cd /path/to/exercise-php-nginx-mysql
docker-compose up -d
```
