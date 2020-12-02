IMAGE ?= supply-chain
IMAGE_DEV ?= $(IMAGE)-dev

DOCKER ?= docker #you can use "podman" as well

.PHONY: init
init:
	# for building the node itself:
	rustup update nightly-2020-10-05
	rustup update stable
	rustup target add wasm32-unknown-unknown --toolchain nightly-2020-10-05
	# for building ERC-721 contract:
	rustup update nightly
	rustup +nightly component add rust-src
	cargo +nightly install cargo-contract --force
	rustup target add wasm32-unknown-unknown --toolchain nightly

.PHONY: check
check:
	SKIP_WASM_BUILD=1 cargo check

.PHONY: test
test:
	SKIP_WASM_BUILD=1 cargo test --release --all

.PHONY: run
run:
	WASM_BUILD_TOOLCHAIN=nightly-2020-10-05 cargo run --release -- --dev --tmp

.PHONY: build
build:
	WASM_BUILD_TOOLCHAIN=nightly-2020-10-05 cargo build --release --all

.PHONY: contract
contract:
	cd erc721 && cargo +nightly contract build

.PHONY: release
release:
	@$(DOCKER) build --no-cache --squash -t $(IMAGE) .

.PHONY: dev-docker-build
dev-docker-build:
	@$(DOCKER) build -t $(IMAGE_DEV) .

.PHONY: dev-docker-run
dev-docker-run:
	@$(DOCKER) run --net=host -it --rm $(IMAGE_DEV) --dev --tmp

.PHONY: dev-docker-inspect
dev-docker-inspect:
	@$(DOCKER) run --net=host -it --rm --entrypoint /bin/bash $(IMAGE_DEV)
