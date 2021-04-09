BUILD_DIR := build

SOUPAULT := esy x soupault

.PHONY: site
site:
	$(SOUPAULT)

.PHONY: site-live
site-live:
	$(SOUPAULT) --profile live

.PHONY: assets
assets:
	cp -r assets/* $(BUILD_DIR)

.PHONY: all
all: site assets

.PHONY: all-live
all-live: site-live assets

.PHONY: gen_index
gen_index:
	esy x soupault --index-only

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: serve
.ONESHELL: serve
serve:
	cd $(BUILD_DIR) && python3 -m http.server

