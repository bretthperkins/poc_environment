# Stage 1: Clone the remote repository
FROM alpine/git:latest AS cloner
WORKDIR /src
ARG REPO_URL="https://github.com/bretthperkins/poc_nodejs"
ARG REPO_BRANCH="main"
# Build-time cache buster to force a fresh git clone when desired
ARG CACHEBUST=0
RUN git clone --single-branch --branch ${REPO_BRANCH} ${REPO_URL} . && \
	echo "cloned ${REPO_URL}@${REPO_BRANCH} (cachebust=${CACHEBUST})"

# Stage 2: Official, fully loaded Node environment
FROM node:22-alpine
WORKDIR /app

# Copy the source code directly from the cloner stage
COPY --from=cloner /src /app

# Install all development dependencies (including nodemon)
RUN npm install

EXPOSE 3000

# Execute the local dev script cleanly
CMD ["npm", "run", "start"]
