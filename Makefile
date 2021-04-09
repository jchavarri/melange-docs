BUILD_DIR := docs/

SOUPAULT := esy x soupault

.PHONY: site
site:
	$(SOUPAULT)

.PHONY: assets
assets:
	cp -r assets/* $(BUILD_DIR)

.PHONY: all
all: site assets

.PHONY: gen_index
gen_index:
	esy x soupault --index-only

.PHONY: clean
clean:
	rm -rf docs/*

.PHONY: serve
.ONESHELL: serve
serve:
	cd docs && python3 -m http.server

