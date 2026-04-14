# ---- Build Frontend ----
FROM node:20-alpine AS frontend
WORKDIR /app
COPY client/package*.json ./
RUN npm ci
COPY client/ ./
RUN npm run build -- --outDir ./dist

# ---- Build Backend ----
FROM golang:1.23-alpine AS backend
WORKDIR /app
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server/ ./
COPY --from=frontend /app/dist ./dist
RUN go build -o bin/server .

# ---- Stage 3: Final image ----
FROM alpine:latest
WORKDIR /app
COPY --from=backend /app/bin/server .
EXPOSE 8080
CMD ["./server"]