#!/bin/bash

echo "Make sure docker and curl is installed"
# Prompt the user for each environment variable, with default values

BASE_URL=https://raw.githubusercontent.com/StarmanMartin/ChemotionTestDeployment/main

curl -fO $BASE_URL/.env.example || exit 1
mv .env.example .env

read -p "Enter public URL [http://0.0.0.0:4000/]: " PUBLIC_URL
PUBLIC_URL=${PUBLIC_URL:-http://0.0.0.0:4000/}

read -p "Enter open docker-compose prot [4000]: " PROJECT_WEB_PORT
PROJECT_WEB_PORT=${PROJECT_WEB_PORT:-4000}

read -p "Enter UPDATE_INTERVAL [600]: " UPDATE_INTERVAL
UPDATE_INTERVAL=${UPDATE_INTERVAL:-600}

sed -i "s|^UPDATE_INTERVAL=.*|UPDATE_INTERVAL=$UPDATE_INTERVAL|" .env
sed -i "s|^PUBLIC_URL=.*|PUBLIC_URL=$PUBLIC_URL|" .env
sed -i "s|^PROJECT_WEB_PORT=.*|PROJECT_WEB_PORT=$PROJECT_WEB_PORT|" .env

echo ".env file created with the following content:"
cat .env

echo "create shared folder"

mkdir -p shared/backup shared/pullin/config shared/restore shared/shell_scripts

echo "Downloading missing files!"

curl -fO $BASE_URL/docker-compose.yml || exit 1
curl -f -o shared/shell_scripts/example.sh $BASE_URL/shared/shell_scripts/example.sh || exit 1
curl -f -o shared/pullin/config/database.yml $BASE_URL/shared/pullin/config/database.yml || exit 1
curl -f -o shared/restore/example.sql $BASE_URL/shared/restore/example.sql || exit 1
curl -f -o shared/BRANCH.txt $BASE_URL/shared/BRANCH.txt || exit 1
curl -f -o shared/client_dependencies.json $BASE_URL/shared/client_dependencies.json || exit 1
curl -f -o shared/server_dependencies.json $BASE_URL/shared/server_dependencies.json || exit 1
