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

# user input indicating prod configuration
$ISPROD=1

# static configurations
$NGINX_CONF="nginx.conf"
$HUGO_PUB="hugo/public"
$HUGO="hugo"
$NGINX="nginx"

if [[ $1 -eq $ISPROD ]]; then
    # paramterize for prod configurations
    echo "Configuring nginx for prod..."
    $USER="www-data"
    $BINPATH="/usr/sbin/"
    $NGINX_BASE="/etc/nginx/"
    $BLOG_ROOT="/home/pi/Documents/blog/"
    $HUGO_PUB="${BLOG_ROOT}${HUGO_PUB}"
    $HUGO_FLAGS="" # build draft posts
    $PORT="80"

    # TODO: replace gateway IP with domain name
    $SERVER_NAME="24.17.207.248"
else
    # paramterize for prod configurations
    echo "Configuring nginx for dev..."
    $USER="aashranand staff"
    $NGINX_BASE="/usr/local/etc/nginx/"
    $BINPATH="/usr/local/bin/"
    $BLOG_ROOT="/Users/aashrayanand/Documents/code/blog/"
    $HUGO_PUB="${BLOG_ROOT}${HUGO_PUB}"
    $HUGO_FLAGS="-D" # build draft posts
    $PORT="8080"
    $SERVER_NAME="localhost"
fi

$NGINX_CONF="${NGINX_BASE}${NGINX_CONF}"

# make updates to temp file, in case there are config errors.
# we will copy to nginx conf dir anyways
$CONFIG="${BLOG_ROOT}${NGINX}/${NGINX}.conf"
$TEMPFILE = "${BLOG_ROOT}${NGINX}/${NGINX}_t.conf"

sudo cp $CONFIG $TEMPFILE
sudo sed -i "s/{USER}/${USER}/g" $CONFIG
sudo sed -i "s/{HUGO}/${HUGO_PUB}/g" $CONFIG
sudo sed -i "s/{PORT}/${PORT}/g" $CONFIG
sudo sed -i "s/{SERVER_NAME}/${SERVER_NAME}/g" $CONFIG
sudo sed -i "s/{NGINX_BASE}/${NGINX_BASE}/g" $CONFIG

# test new config
sudo ${BINPATH}${NGINX} -t -c $TEMPFILE 2>/dev/null

# re-load config if successful, and also re-generate hugo content
if [[ $? -eq 0 ]]; then
    echo "Re-loading nginx with new config..."
    sudo cp $TEMPFILE $NGINX_CONF
    sudo ${BINPATH}${NGINX} -s reload

    # generate hugo content
    cd ${BLOG_ROOT}
    sudo ${BINPATH}${HUGO} $HUGO_FLAGS

    if [[ $? -eq 0 ]]; then
        echo "Re-generated hugo content..."
        echo "Successfully refreshed server and contents. goodbye..."
        return 0
    else
        echo "Hugo generation has build errors, see below..."
        echo $?
    fi
else
    echo "New config has build errors, see below..."
    echo $?
fi

return 1

