#!/bin/bash

echo $$ > $PIDFILE

clone_repo () {
  LOCALREPO_VC_DIR=$3/.git
  if [ -d "$LOCALREPO_VC_DIR" ]
  then
    cd "$3"
    cd ..
    rm -r "$3"
    mkdir "$3"
  fi
  git clone -b $2 "$1" "$3"
}

REPOR=https://github.com/ComPlat/chemotion_ELN.git
LOCALREPO=/chemotion/chem


ELN_BRANCH=${ELN_BRANCH:-main}

echo "|================================================================================|"
echo "|  Cloning Chemotion Branch: ${ELN_BRANCH}  "
echo "|================================================================================|"
clone_repo $REPOR ${ELN_BRANCH} $LOCALREPO

cd $LOCALREPO

./prepare-asdf.sh
asdf reshim
asdf install
npm install yarn -g
../replace_client_dependencies.sh
../replace_server_dependencies.sh
./prepare-nodejs.sh
yarn install

cd /chemotion