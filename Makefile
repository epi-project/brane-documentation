.PHONY: all
all: build build/user-guide build/specification build/tutorials

.PHONY: build
build:
	mdbook build main
	cp -r main/book build

.PHONY: build/user-guide
build/user-guide:
	mdbook build user-guide
	cp -r user-guide/book build/user-guide

.PHONY: build/specification
build/specification:
	mdbook build specification
	cp -r specification/book build/specification


.PHONY: build/tutorials
build/tutorials:
	mdbook build tutorials
	cp -r tutorials/book build/tutorials

.PHONY: clean
clean:
	rm -r build
