.PHONY: build test

build:
	protostar build --cairo-path=src

test:
	protostar test --cairo-path=src src/onlydust/stream/tests/
