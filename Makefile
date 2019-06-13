LUA ?= lua

sed = $(LUA) scripts/sed.lua
mkver = $(LUA) scripts/mkver.lua
mkpath = $(LUA) scripts/mkpath.lua

rock_name = ldk-core
rock_version := $(shell $(mkver))
rockspec = rockspecs/$(rock_name)-$(rock_version)-1.rockspec

makefile_path = $(abspath $(lastword $(MAKEFILE_LIST)))
cwd = $(patsubst %/,%,$(dir $(makefile_path)))
cwd_unix := $(shell $(mkpath) $(cwd))

circleci = 	docker run --interactive --tty --rm \
	--volume //var/run/docker.sock:/var/run/docker.sock \
	--volume $(cwd):$(cwd_unix) \
	--volume $(HOME)/.circleci:/root/.circleci \
	--workdir $(cwd_unix) \
	circleci/picard@sha256:f340abec0d267609a4558a0ff74538227745ef350ffb664e9dbb39b1dfc20100

.PHONY: $(rockspec) spec docs lint

default: spec

docs: build-aux/config.ld.in
	$(sed) build-aux/config.ld.in build-aux/config.ld ROCK_NAME=$(rock_name) ROCK_VERSION=$(rock_version)
	ldoc -c build-aux/config.ld .

lint:
	luacheck src
	luacheck spec

spec:
	busted -o plainTerminal

coverage:
	busted -o plainTerminal -c
	luacov
	luacov -r default

build: rockspec
	luarocks make $(rockspec)

build-dev: rockspec-dev
	luarocks make

circleci-build:
	$(circleci) circleci build --job build

circleci-shell:
	$(circleci)

rockspec-dev:
	$(sed) rockspecs/$(rock_name).rockspec.in rockspecs/$(rock_name)-dev-1.rockspec ROCK_NAME=$(rock_name) ROCK_VERSION=dev

rockspec: rockspecs/$(rock_name).rockspec.in
	$(sed) rockspecs/$(rock_name).rockspec.in $(rockspec) ROCK_NAME=$(rock_name) ROCK_VERSION=$(rock_version)

publish: rockspec
	luarocks upload --temp-key=$(LDK_LUAROCKS_KEY) $(rockspec)
