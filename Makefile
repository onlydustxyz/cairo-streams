.PHONY: build test

build:
	protostar build

test:
	protostar test src/ -m '.*$(match).*'
