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