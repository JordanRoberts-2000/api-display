IMAGE      := jordanroberts2000/api-display
SERVER_DIR := server
CLIENT_DIR := client
COMPOSE    := docker compose -f /opt/api-display/docker-compose.prod.yml

.PHONY: push ssh restart deploy bootstrap infra provision \
        dev dev-server dev-client \
        build build-client build-server \
        run-server clean

push:
	docker build -t $(IMAGE):latest .
	docker push $(IMAGE):latest

ssh:
	$(eval EC2_IP := $(shell terraform -chdir=terraform output -raw public_ip))
	ssh -i ~/.ssh/aws/aws-main.pem admin@$(EC2_IP)

restart:
	$(eval EC2_IP := $(shell terraform -chdir=terraform output -raw public_ip))
	ssh -i ~/.ssh/aws/aws-main.pem admin@$(EC2_IP) "sudo bash -s" < scripts/restart.sh

deploy:
	$(MAKE) push
	$(MAKE) restart

bootstrap:
	$(eval EC2_IP := $(shell terraform -chdir=terraform output -raw public_ip))
	ssh -i ~/.ssh/aws/aws-main.pem admin@$(EC2_IP) "sudo bash -s" < scripts/bootstrap.sh

infra:
	terraform -chdir=terraform apply -auto-approve

destroy:
	terraform -chdir=terraform destroy

dev:
	$(MAKE) -j2 dev-server dev-client

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