Place startup scripts in /etc/init
And make sure to install upstart

Nginx conf file requires a user with root privileges (this may be blasphemy)
Also a copy in the same folder

connect:
ssh -i arrangedMarriageServer.pem ec2-user@184.169.134.227

the repo is in /code
:
restart all services:
sudo ~/restart_services.sh

get a list of running services:
initctl list


start/stop individual services:
stop nginx
stop nodejs
stop redis

start redis
start nodejs
start nginx

the services above are controlled via corresponding files in /etc/init

to update everything after code changes:
git pull && sudo ~/restart_services.sh  && initctl list
password: 1ntr0ducere

You may need to also run rake db:migrate from the touchEnd directory