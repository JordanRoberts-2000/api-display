SERVER_DIR := server
CLIENT_DIR := client

dev:
	$(MAKE) -j 2 dev-server dev-client

dev-server:
	cd $(SERVER_DIR) && air

dev-client:
	cd $(CLIENT_DIR) && npm run dev

build: build-client build-server

build-client:
	cd $(CLIENT_DIR) && npm run build

build-server:
	cd $(SERVER_DIR) && go build -o ./bin/server .

run: build
	./$(SERVER_DIR)/bin/server

clean:
	rm -rf $(SERVER_DIR)/bin $(SERVER_DIR)/dist