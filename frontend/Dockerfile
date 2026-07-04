# Stage 1: Clone the remote repository
FROM alpine/git:latest AS cloner
WORKDIR /src

ARG GITHUB_PAT
ARG REPO_URL
ARG REPO_BRANCH="main"
ARG CACHEBUST=0

RUN git clone --single-branch --branch ${REPO_BRANCH} ${REPO_URL} . && \
    echo "Cloned ${REPO_URL}@${REPO_BRANCH} (cachebust=${CACHEBUST})"

# Stage 2: Install dependencies and build Next.js
FROM node:22-alpine AS builder
WORKDIR /app

COPY --from=cloner /src /app

RUN npm install
RUN npm run build

# Stage 3: Production runtime
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package*.json ./

RUN npm install --omit=dev

EXPOSE 3000
CMD ["npm", "start"]
