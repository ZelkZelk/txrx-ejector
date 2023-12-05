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
    npm install --save ../txrx/redis
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
        | sed "s/\.\/telemetry/\./g"                                    \
        | sed "s/HANDLERS_DIR: backend/HANDLERS_DIR: \.\.\/backend/g"    \
        > docker-compose.yml
fi

if [[ ! -d "otelcol" ]] ;
then
    project="${PWD##*/}"
    cp -R txrx/telemetry/otelcol otelcol

    cat txrx/telemetry/otelcol/otelcol-observability.yml | sed "s/txrx/$project/g" > otelcol/otelcol-observability.yml
fi

if [[ ! -f "docker-compose.dev.yml" ]] ;
then
    project="${PWD##*/}"
    cat txrx/docker-compose.dev.yml | grep version > docker-compose.dev.yml
    echo -e "\nservices:" >> docker-compose.dev.yml
    echo -e "  rpc:" >> docker-compose.dev.yml
    echo -e "    volumes:" >> docker-compose.dev.yml
    echo -e "      - ./backend:/usr/backend" >> docker-compose.dev.yml
    echo -e "  rpc-auth:" >> docker-compose.dev.yml
    echo -e "    volumes:" >> docker-compose.dev.yml
    echo -e "      - ./backend:/usr/backend" >> docker-compose.dev.yml
fi

if [[ ! -f Makefile ]] ;
then
    project="${PWD##*/}"
    cat txrx/Makefile | sed "s/\-d \"txrx\"/\-d \"\ZZZZZ\"/g" | sed "s/cd txrx/cd ZZZZZ/g" | sed "s/txrx/$project/g" | sed "s/ZZZZZ/txrx/g" > Makefile
fi

if [[ ! -f Dockerfile ]] ;
then
    project="${PWD##*/}"
    cat txrx/Dockerfile                                                 \
        | sed "s/COPY \.\/ \/usr\/app/COPY \.\/txrx \/usr\/app\n\nCOPY \.\/backend \/usr\/backend/g"  \
        | sed "s/ENTRYPOINT/RUN ln -s \/usr\/app \/usr\/txrx\n\nRUN if [ \"\${PACKAGE}\" = 'rpc' ] ; then cd \/usr\/backend \&\& npm link \.\.\/txrx\/rpc \&\& npm install \&\& rm \-rf \/usr\/backend\/dist \&\& npx tsc; fi\n\nENTRYPOINT/g" \
        > Dockerfile
fi 

if [[ ! -f nodemon.json ]]
then
    cat txrx/nodemon.json | sed "s/make reload/make rpc_restart/g" > nodemon.json
fi
