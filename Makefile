.PHONY: build test

build:
	protostar build

test:
	protostar test tests/ -m '.*$(match).*'
