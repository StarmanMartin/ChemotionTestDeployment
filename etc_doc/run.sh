#!/bin/bash

echo $$ > $PIDFILE

LOCALREPO=/chemotion/chem


echo "|================================================================================|"
echo "|  Setting up defaults  "
echo "|================================================================================|"

CONF="$LOCALREPO"/config

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


# asdf tools are installed in clone_repo.sh; prepare-nodejspkg.sh installs yarn and runs yarn install
./prepare-rubygems.sh || { echo "prepare-rubygems.sh failed"; exit 1; }
# prepare-rubygems.sh may not propagate a killed bundle install, so verify the gems explicitly
bundle check || { echo "Ruby gems missing (bundle install failed, possibly out of memory)"; exit 1; }
./prepare-nodejspkg.sh || { echo "prepare-nodejspkg.sh failed"; exit 1; }

export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
export RAILS_ENV=production


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
  rm -f $RAILS_PIDFILE
fi

RAILS_FORCE_SSL=false bundle exec rails s -b 0.0.0.0 -p4000 --pid "${RAILS_PIDFILE}"



