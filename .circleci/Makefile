build:
	luarocks make rockspecs/ldk-0.1.0-1.rockspec

spec:
	mkdir -p /tmp/test-reports
	busted -o junit -Xoutput /tmp/test-reports/result.xml

coverage:
	busted -c
	luacov-coveralls -v

lint:
	mkdir -p /tmp/test-reports/luacheck
	luacheck --formatter JUnit src/ldk >> /tmp/test-reports/luacheck/ldk.xml
	luacheck --formatter JUnit spec >> /tmp/test-reports/luacheck/spec.xml
