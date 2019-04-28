LUA ?= lua

sed = $(LUA) scripts/sed.lua
mkver = $(LUA) scripts/mkver.lua
mkpath = $(LUA) scripts/mkpath.lua

rock_version = $(shell $(mkver))
rockspec = rockspecs/ldk-core-$(rock_version)-1.rockspec
rockspec-dev = rockspecs/ldk-core-dev-1.rockspec

.PHONY: rockspec-dev rockspec package.json .circleci/Makefile spec docs

default: spec

docs: build-aux/config.ld.in
	$(sed) build-aux/config.ld.in build-aux/config.ld ROCK_VERSION=$(rock_version)
	ldoc -c build-aux/config.ld .

lint: rockspec
	luacheck $(rockspec)
	luacheck spec

spec: build
	luarocks test

coverage: build
	luarocks test -- -c
	luacov
	luacov -r default

build: rockspec-dev
	luarocks make --local

publish: rockspec
	luarocks upload --temp-key=$(LDK_LUAROCKS_KEY) $(rockspec)

changelog: package.json
	conventional-changelog -a -p angular -i CHANGELOG.md -s -r 0

genfiles: rockspec-dev rockspec package.json .circleci/Makefile

rockspec-dev: rockspecs/rockspec.in
	$(sed) rockspecs/rockspec.in $(rockspec-dev) ROCK_VERSION=dev

rockspec: rockspecs/rockspec.in
	$(sed) rockspecs/rockspec.in $(rockspec) ROCK_VERSION=$(rock_version)

package.json: package.json.in
	$(sed) package.json.in package.json ROCK_VERSION=$(rock_version)

.circleci/Makefile: .circleci/Makefile.in
	$(sed) .circleci/Makefile.in .circleci/Makefile ROCK_VERSION=$(rock_version)

prepare-release: docs genfiles changelog
