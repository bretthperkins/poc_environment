#!/bin/sh
set -eu

REPO_URL="${REPO_URL:-https://github.com/bretthperkins/poc_nodejs}"
REPO_BRANCH="${REPO_BRANCH:-main}"
APP_DIR="/app"

echo "Syncing application code from ${REPO_URL}@${REPO_BRANCH}"

if [ -d "${APP_DIR}/.git" ]; then
  git -C "${APP_DIR}" fetch --depth=1 origin "${REPO_BRANCH}"
  git -C "${APP_DIR}" checkout -f "${REPO_BRANCH}"
  git -C "${APP_DIR}" reset --hard "origin/${REPO_BRANCH}"
else
  rm -rf "${APP_DIR}"
  git clone --single-branch --branch "${REPO_BRANCH}" "${REPO_URL}" "${APP_DIR}"
fi

# Keep runtime env variable naming compatible with the API code.
find "${APP_DIR}" -type f -name "*.js" -print0 \
  | xargs -0 sed -i \
    -e "s/process.env.DB_SERVER_USER/process.env.API_DB_SERVER_USER/g" \
    -e "s/process.env.DB_SERVER_PASSWORD/process.env.API_DB_SERVER_PASSWORD/g" \
    -e "s/process.env.DB_SERVER_HOST/process.env.API_DB_SERVER_HOST/g" \
    -e "s/process.env.DB_SERVER_PORT/process.env.API_DB_SERVER_PORT/g" \
    -e "s/process.env.DB_SERVER_INSTANCE/process.env.API_DB_SERVER_INSTANCE/g" || true

cd "${APP_DIR}"
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

exec npm run start
