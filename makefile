.PHONY: test

EXEC:=fireward

test:
	stack test --file-watch

exec-path: 
	@echo "$(shell stack path --dist-dir)/build/fireward/fireward"
	
tmp/try.rules: ./.stack-work/dist/x86_64-osx/Cabal-1.24.2.0/build/fireward/fireward
tmp/try.rules: $(file) 
	test -r "$(file)"
	stack exec fireward -- -i $(file) > tmp/try.rules
	cat tmp/try.rules	

try: $(file)
	stack build
	test -r "$(file)"
	stack exec fireward -- -i $(file) 


prefix?=/usr/local/bin
PREFIX:=$(prefix)


LOCAL_PATH:=$(shell stack path --local-bin)
install: 
	stack install && cp $(LOCAL_PATH)/$(EXEC) $(prefix)/

VERSION=$(shell stack exec fireward -- -V)

buildtest:
	stack build	
	# stack test

V=$(shell stack exec fireward -- -V)
tag:
	git tag -a "$(V)"

release:
	make buildtest
	git push origin master # prevent travis from building anything but the tag
	make tag
	git push origin master --follow-tags

v?=$(V)
publish: 
	cd npm-bin && ./publish.sh
workExe:=$(shell stack path --dist-dir)/build/fireward/fireward

watch-complex:
	watch -i 1 make .test-complex
.test-complex: $(workExe)
	@stack build
	touch .test-complex
	$(workExe) -i ./test/fixtures/indent.ward

smoke-test:
	cat examples/smoke-test.ward | stack exec fireward
