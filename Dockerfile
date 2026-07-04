# Stage 1: Clone the remote repository
FROM alpine/git:latest AS cloner
WORKDIR /src

# Add curl for debugging
RUN apk add --no-cache curl

ARG REPO_URL="https://github.com/bretthperkins/poc_nodejs"
ARG REPO_BRANCH="main"
# Build-time cache buster to force a fresh git clone when desired
ARG CACHEBUST=0

# NEW LINE: force cache invalidation every build
RUN echo "Cachebust: ${CACHEBUST} - $(date)" > /tmp/cachebust.txt

RUN git clone --single-branch --branch ${REPO_BRANCH} ${REPO_URL} . && \
	echo "cloned ${REPO_URL}@${REPO_BRANCH} (cachebust=${CACHEBUST})"

# Stage 2: Official, fully loaded Node environment
FROM node:22-alpine
WORKDIR /app

# Runtime git is required to refresh code from the remote branch at container start.
RUN apk add --no-cache git

# Copy the source code directly from the cloner stage
COPY --from=cloner /src /app

# Startup wrapper syncs code from remote branch each time the container starts.
COPY ./scripts/start_api.sh /usr/local/bin/start_api.sh
RUN chmod +x /usr/local/bin/start_api.sh

# Replace legacy DB_SERVER_* env accesses with API_DB_SERVER_* at build time
# This updates source files cloned from the remote repo so the app uses the
# new API-prefixed environment variables.
RUN find /app -type f -name "*.js" -print0 \
	| xargs -0 sed -i \
		-e "s/process.env.DB_SERVER_USER/process.env.API_DB_SERVER_USER/g" \
		-e "s/process.env.DB_SERVER_PASSWORD/process.env.API_DB_SERVER_PASSWORD/g" \
		-e "s/process.env.DB_SERVER_HOST/process.env.API_DB_SERVER_HOST/g" \
		-e "s/process.env.DB_SERVER_PORT/process.env.API_DB_SERVER_PORT/g" \
		-e "s/process.env.DB_SERVER_INSTANCE/process.env.API_DB_SERVER_INSTANCE/g" || true

# Install all development dependencies (including nodemon)
RUN npm install

EXPOSE 3000

# Pull latest branch code and then start the API process.
CMD ["/usr/local/bin/start_api.sh"]
