# Dockerized Shopware 4.3.0

If you `git clone`d this repo, run

    sudo docker build -t shopware .

to build the image and name it `shopware`.

To run this container, please provide the necessary volume to hold the
MySQL server databases and the Shopware files like this:

    sudo docker run -it -t shopware \
      -v /docker-volumes/shopware:/volume \
      -p 8080:80 \
      shopware /bin/bash

On the first start (when the volume is still empty), the MySQL databases
will be initialized and `/usr/bin/mysql_secure_installation` is run to
let you set a root password.

After the first start, a random password has been assigned for the HTTP
authentication of the phpMyAdmin pages. It is written to the volume as
`phpmyadmin-htpasswd.txt`. The username is `phpmyadmin`.
In the example above, you would find the
password in this directory of the host:

    /docker-volumes/shopware/phpmyadmin-htpasswd.txt

# Authors

* Philipp Adelt <info@philipp.adelt.net>
