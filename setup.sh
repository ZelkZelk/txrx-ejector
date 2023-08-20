#!/bin/bash

origin=$(git remote get-url origin);

if [[ ! -z "$origin" ]] ;
then
    git submodule init
    git submodule update
fi

if [[ "$origin" == "git@github.com:ZelkZelk/txrx-example.git" ]] ;
then
    git remote rm origin
fi

if [[ ! -d backend ]] ;
then
    cp txrx/backend -R backend
fi

if [[ ! -d frontend ]] ;
then
    cp txrx/frontend -R frontend
fi

if [[ ! -f "docker-compose.yml" ]] ;
then
    project="${PWD##*/}"
    cat txrx/docker-compose.yml                                       \
        | sed "s/txrx/$project/g"                                      \
        | sed "s/HANDLERS_DIR: backend/HANDLERS_DIR: \.\.\/backend/g"   \
        | sed "s/context: \.\//context: \.\/\n      working_dir: \/txrx/g" > docker-compose.yml
fi

if [[ ! -f Makefile ]] ;
then
    project="${PWD##*/}"
    cat txrx/Makefile                                                 \
        | sed "s/txrx/$project/g"                                      \
        | tr '\n' '\r'                                                  \
        | sed "s/node_clean:/node_clean:\r\trm -rf backend\/dist backend\/node_modules frontend\/dist frontend\/node_modules\r\tcd backend \&\& npm i \&\& cd \.\.\/frontend \&\& npm i\r\rws:/g"   \
        | sed "s/ws:.*ws:/ws:/"   \
        | tr '\r' '\n' \
        > Makefile
fi