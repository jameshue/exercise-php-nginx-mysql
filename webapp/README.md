# 如何開發一個 Laravel + MySQL 框架的 Docker 化應用

> 目標：基于主流的 PHP 框架，用 Docker 鏡像的方式搭建一個 Laravel + MySQL 的應用。

### 創建 Laravel 應用容器

首先，選擇官方的 PHP 鏡像作為項目的基礎鏡像。

```dockerfile
FROM daocloud.io/php:5.6-apache
```

其次，通過安裝腳本安裝 Laravel 應用所需要的 PHP 依賴。

```dockerfile
# 安裝 PHP 相關的依賴包，如需其他依賴包在此添加
RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libz-dev \
        git \
        wget \

    # 官方 PHP 鏡像內置命令，安裝 PHP 依賴
    && docker-php-ext-install \
        mcrypt \
        mbstring \
        pdo_mysql \
        zip \


    # 用完包管理器後安排打掃衛生可以顯著的減少鏡像大小
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

    # 安裝 Composer，此物是 PHP 用來管理依賴關系的工具
    && curl -sS https://getcomposer.org/installer \
        | php -- --install-dir=/usr/local/bin --filename=composer
```

* 依賴包通過 `docker-php-ext-install` 安裝，如果依賴包需要配置參數則通過 `docker-php-ext-configure` 命令。
* Docker 鏡像採用分層數據存儲格式，鏡像的大小等于所有層次大小的總和，所以我們應該盡量精簡每次構建所產生鏡像的大小。
* Composer 為 Laravel 下載第三方 Vendor 包所必需的插件，Composer 同時也是 PHP 最流行的包管理工具。

接著，創建 Laravel 目錄結構：

```dockerfile
# 開啟 URL 重寫模塊
# 配置默認放置 App 的目錄
RUN a2enmod rewrite \
    && mkdir -p /app \
    && rm -fr /var/www/html \
    && ln -s /app/public /var/www/html

WORKDIR /app
```

* Laravel 是通過統一的項目的入口文件進入應用系統的。進而需要 Apache 開啟鏈接重寫模塊。
* Apache 默認的文檔目錄為 `/var/www/html`，將 `/app` 定義為 Laravel 應用目錄，而 Laravel 的項目入口文件位于 `/app/public`。為了方便管理，把 `/var/www/html` 軟鏈接到 `/app/public`。

緊接著，根據最佳實踐，我們需要把第三方依賴預先加載好。

```dockerfile
# 預先加載 Composer 包依賴，優化 Docker 構建鏡像的速度
COPY ./composer.json /app/
COPY ./composer.lock /app/
RUN composer install  --no-autoloader --no-scripts
```

* 復制 `composer.json` 和 `composer.lock` 到 `/app`, `composer.lock` 會鎖定 Composer 加載的依賴包版本號，防止由于第三方依賴包的版本不同導致的應用運行錯誤。
* `--no-autoloader` 為了阻止 `composer install` 之後進行的自動加載，防止由于代碼不全導致的自動加載報錯。
* `--no-scripts` 為了阻止 `composer install` 運行時 `composer.json` 所定義的腳本，同樣是防止代碼不全導致的加載錯誤問題。

然後，將 Laravel 應用程序復制到 `/app`：

```dockerfile
# 復制代碼到 App 目錄
COPY . /app

# 執行 Composer 自動加載和相關腳本
# 修改目錄權限
RUN composer install \
    && chown -R www-data:www-data /app \
    && chmod -R 0777 /app/storage
```

* `composer install` 執行之前阻止的操作，完成自動加載及腳本運行
* 修改 `/app` 與 `/app/storage` 的權限，保證 Laravel 在運行中有足夠的權限
* 因為基礎鏡像內已經聲明了暴露端口和啟動命令，此處可以省略。

至此，包含 Laravel 應用的 Docker 容器已經準備好了。Laravel 代碼中訪問數據庫所需的參數，是通過讀取環境變量的方式聲明的。

`config/database.php` 修改變量為更貼近 Docker 的方式：

```php
'host'      => env('MYSQL_PORT_3306_TCP_ADDR', 'localhost'),
'database'  => env('MYSQL_INSTANCE_NAME', 'forge'),
'username'  => env('MYSQL_USERNAME', 'forge'),
'password'  => env('MYSQL_PASSWORD', ''),
```

這樣做是因為在 Docker 化應用開發的最佳實踐中，通常將有狀態的數據類服務放在另一個容器內運行，並通過容器特有的 `link` 機制將應用容器與數據容器動態的連接在一起。

### 綁定 MySQL 數據容器（本地）

首先，需要創建一個 MySQL 容器。

```bash
docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d daocloud.io/mysql:5.5
```

之後，通過 Docker 容器間的 `link` 機制，便可將 MySQL 的默認端口 (3306) 暴露給應用容器。

```bash
docker run --name some-app --link some-mysql:mysql -d app-that-uses-mysql
```

### php-laravel-mysql-sample 應用截圖

![php-laravel-mysql-sample](/php-laravel-mysql-sample.png "php-laravel-mysql")
