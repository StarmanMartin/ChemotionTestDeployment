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

REPO=https://github.com/ComPlat/chemotion_ELN.git
LOCALREPO=/chemotion/chem


ELN_BRANCH=${ELN_BRANCH:-main}

echo "|================================================================================|"
echo "|  Cloning Chemotion Branch: ${ELN_BRANCH}  "
echo "|================================================================================|"
clone_repo $REPO ${ELN_BRANCH} $LOCALREPO

CONF="$LOCALREPO"/config

echo "|================================================================================|"
echo "|  Setting up defaults  "
echo "|================================================================================|"

cp -f "$CONF"/datacollectors.yml.example "$CONF"/datacollectors.yml
cp -f "$CONF"/profile_default.yml.example "$CONF"/profile_default.yml
cp -f "$CONF"/shrine.yml.example "$CONF"/shrine.yml
cp -f "$CONF"/storage.yml.example "$CONF"/storage.yml
cp -f "$CONF"/radar.yml.example "$CONF"/radar.yml

cp -RT /shared/ "$LOCALREPO"

mkdir -p "$LOCALREPO"/lib/tasks

cp -RT /chemotion/db_restore.rake "$LOCALREPO"/lib/tasks/db_restore.rake
cp -RT /chemotion/db_backup.rake "$LOCALREPO"/lib/tasks/db_backup.rake

cd "$LOCALREPO"

echo "|================================================================================|"
echo "|  Installing dependencies "
echo "|================================================================================|"

./prepare-asdf.sh
./prepare-nodejs.sh
./prepare-rubygems.sh
./prepare-nodejspkg.sh

export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
export RAILS_ENV=production

asdf reshim ruby
EDITOR="mate --wait" RAILS_ENV=production bundle exec rails credentials:edit

echo "|================================================================================|"
echo "|  Preparing Database "
echo "|================================================================================|"

if bundle exec rake db:version > /dev/null 2>&1; then
  echo "Database exists."
  bundle exec rails db:backup
else
  echo "Database does not exist."
  bundle exec rake db:create
  bundle exec rake db:migrate
  bundle exec rake db:seed
fi

bundle exec rails db:restore

echo "|================================================================================|"
echo "|  Building client "
echo "|================================================================================|"

./bin/shakapacker

echo "|================================================================================|"
echo "|  Running server "
echo "|================================================================================|"
# tail -f /dev/null
if [ -f $RAILS_PIDFILE ]; then
  kill -TERM $(cat $RAILS_PIDFILE)
  rm -f $$RAILS_PIDFILE
fi

RAILS_FORCE_SSL=false bundle exec rails s -b 0.0.0.0 -p4000 --pid "${RAILS_PIDFILE}"



