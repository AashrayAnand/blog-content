#!/bin/bash
# simple bash script to configure nginx variables, since
# nginx does not use run-time variable configuration management
# and chooses instead to use static configurations for best performance

# options will be to either configure dev (0) or prod (1) nginx config

# prod machine is a raspberry pi where
# 1. nginx path is /etc/nginx
# 2. we use port 80 to listen for http
# 3. hugo content root is /home/pi/Documents/blog/hugo/public
# 4. nginx exe at /usr/sbin/nginx
# 5. using systemctl for starting/stopping nginx
# 6. user is

# dev machine is a macbook where
# 1. nginx path is /usr/local/etc/nginx
# 2. we use port 8080 to listen for http
# 3. hugo content root is /Users/aashrayanand/Documents/code/blog/hugo/public;
# 4. nginx exe at /usr/local/bin/nginx
# 5. using brew services for starting/stopping nginx
# 6. user is local admin

# after pre-processing config file, last step should be to verify
# the new config is actually valid, and only then replacing the existing config
# and reloading nginx

# static configurations
NGINX_CONF="nginx.conf"
PUBLIC="public/"
HUGO_DIR="hugo/"
HUGO="hugo"
HUGO_PUB="${HUGO_DIR}${PUBLIC}"
NGINX="nginx"

if [[ $1 -eq 1 ]]; then
    # paramterize for prod configurations
    echo "Configuring nginx for prod..."
    USER="www-data"
    BINPATH="/usr/sbin/"
    NGINX_ROOT="/etc/nginx/"
    BLOG_ROOT="/home/pi/Documents/blog/"
    HUGO_FLAGS=""
    PORT="80"

    # TODO: replace gateway IP with domain name
    SERVER_NAME="24.17.207.248"
else
    # paramterize for prod configurations
    echo "Configuring nginx for dev..."
    USER="aashrayanand staff"
    NGINX_ROOT="/usr/local/etc/nginx/"
    BINPATH="/usr/local/bin/"
    BLOG_ROOT="/Users/aashrayanand/Documents/code/blog/"
    HUGO_FLAGS="-D" # build draft posts
    PORT="8080"
    SERVER_NAME="localhost"
fi


HUGO_PUB="${BLOG_ROOT}${HUGO_PUB}"
NGINX_CONF="${NGINX_ROOT}${NGINX_CONF}"

# make updates to temp file, in case there are config errors.
# we will copy to nginx conf dir anyways
CONFIG="${BLOG_ROOT}${NGINX}/${NGINX}.conf"
TEMPFILE="${BLOG_ROOT}${NGINX}/${NGINX}_t.conf"

if [ -f "$TEMPFILE" ]; then
    echo "$TEMPFILE exists. Removing it..."
    sudo rm $TEMPFILE
fi

sudo cp $CONFIG $TEMPFILE

# string replace with configs
sudo sed -i'.original' "s%{USER}%${USER}%g" $TEMPFILE
sudo sed -i'.original' "s%{HUGO_STAT}%${BLOG_ROOT}${HUGO_DIR}%g" $TEMPFILE
sudo sed -i'.original' "s%{HUGO_PUB}%${HUGO_PUB}%g" $TEMPFILE
sudo sed -i'.original' "s%{PORT}%${PORT}%g" $TEMPFILE
sudo sed -i'.original' "s%{SERVER_NAME}%${SERVER_NAME}%g" $TEMPFILE
sudo sed -i'.original' "s%{NGINX_ROOT}%"${NGINX_ROOT}"%g" $TEMPFILE

# test new config
sudo ${BINPATH}${NGINX} -t -c $TEMPFILE

# re-load config if successful, and also re-generate hugo content
if [[ $? -eq 0  ]]; then
    # generate hugo content
    cd ${BLOG_ROOT}/hugo
    sudo ${BINPATH}${HUGO} $HUGO_FLAGS

    if [[ $? -eq 0 ]]; then
        echo "Re-generated hugo content..."

        echo "Re-loading nginx with new config..."
        sudo cp $TEMPFILE $NGINX_CONF
        sudo ${BINPATH}${NGINX} -s reload

        echo "Successfully refreshed server and contents. goodbye..."
        exit 0
    else
        echo "Hugo generation has build errors, see below..."
        echo $?
        exit 1
    fi
else
    echo "Nginx config has build errors, see below..."
    echo $?
    exit 1
fi

exit 1

