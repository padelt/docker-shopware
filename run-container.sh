#!/bin/bash
sudo docker run --rm -it -v /docker-volumes/shopware:/volume -p 8001:80 shopware
