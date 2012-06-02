#!/bin/sh
# This is a comment
stop nginx
stop nodejs
stop redis

start redis
start nodejs
start nginx
