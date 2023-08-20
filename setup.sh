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
    project="${PWD##*/}"
    cp txrx/backend -R backend
    cd backend
    npm install --save ../txrx/rpc
    npm install --save ../txrx/streamer
    npm install --save ../txrx/consumer

    cat ../txrx/backend/Makefile                                       \
        | sed "s/txrx/$project/g"                                      \
        > Makefile

    cat ../txrx/backend/config/config.json                             \
        | sed "s/txrx/$project/g"                                      \
        > config/config.json

    cd ..
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
        > docker-compose.yml
fi

if [[ ! -f Makefile ]] ;
then
    project="${PWD##*/}"
    cat txrx/Makefile                                                 \
        | sed "s/txrx/$project/g"                                      \
        | tr '\n' '\r'                                                  \
        | sed "s/node_clean:/node_clean:\r\trm -rf backend\/dist backend\/node_modules frontend\/dist frontend\/node_modules\r\tcd backend \&\& npm i \&\& cd \.\.\/frontend \&\& npm i\r\stop:/g"   \
        | sed "s/stop:.*ws:/stop:/"   \
        | tr '\r' '\n' \
        > Makefile
fi

if [[ ! -f Dockerfile ]] ;
then
    project="${PWD##*/}"
    cat txrx/Dockerfile                                                 \
        | sed "s/COPY \.\/ \/usr\/app/COPY \.\/txrx \/usr\/app\n\nCOPY \.\/backend \/usr\/backend/g"  \
        | sed "s/ENTRYPOINT/RUN ln -s \/usr\/app \/usr\/txrx\n\nRUN cd \/usr\/backend \&\& npm link \.\.\/txrx\/rpc \&\& npm install \&\& rm \-rf \/usr\/backend\/dist \&\& npx tsc\n\nENTRYPOINT/g" \
        > Dockerfile
fi