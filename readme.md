![image](doc/nomads-thumbnail.png)

# Deploy on VM

1. Install PHP

```bash
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php7.4-fpm
sudo php-fpm7.4 -v
```

2. Install Depedencies

```bash 
sudo apt install php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl php7.4-bcmath -y
```

3. Install Composer

 - Download composer
```bash
wget https://getcomposer.org/composer-stable.phar
```


 - Install composer

```bash
chmod 755 composer-stable.phar
mv composer-stable.phar /usr/local/bin/composer
```

4. Install Nginx

```bash 
sudo apt update
sudo apt install nginx
```

5. Clone project 

clone project form github to this path
```bash
cd /var/www
```

```bash
# /var/www
git clone [URL_GIT]
```

6. Update Depedencies Laravel
```bash
# /var/www
cd [URL_GIT]
```
```bash
# /var/www/URL_GIT
composer update
```

7. Coppy Env
```bash
# /var/www/URL_GIT
cp .env.example .env
```

8. Generate Key
```bash
# /var/www/URL_GIT
php artisan key:generate
```

9. Add config Nginx
```bash
# /var/www/URL_GIT
vi /vim /etc/nginx/sites-enabled/[NAMA_WEBSITE]
```
```bash
server {
    listen 80;
    server_name [IP/DOMAIN];
    root /var/www/[GIT_REPO]/public;


    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

10. Check Config Nginx and reload Nginx
```bash
    nginx -t
```
```bash
    systemctl restart nginx
```