CURL    ?= curl
PYTHON  ?= python3
CONVERT ?= convert

# Needs to be built with `cargo build --release --features=lzma` from within
# the exporter directory
RUFFLE  ?= ~/src/ruffle/target/release/exporter

W       ?= 128
H       ?= 80

ZPREFIX = z0r-de_
ZFIRST  = 0
ZLAST   = 7953

# Error in Queue::write_texture: copy of 0..173352 would end up overruning the
# bounds of the Source buffer of size 57784 (src/backend/direct.rs:130:9)
EXCLUDE += 4167 6009

# Infinite (very long?) loop
EXCLUDE += 1703 1931 2021 6212

# 404
EXCLUDE += 2381 7546

# MP4 file
EXCLUDE += 3099

ZLIST = $(filter-out $(EXCLUDE),$(shell seq $(ZFIRST) $(ZLAST)))
REFS  = $(addsuffix .png,$(addprefix ref/$(ZPREFIX),$(ZLIST)))
SWFS  = $(addsuffix .swf,$(addprefix swf/$(ZPREFIX),$(ZLIST)))

all: $(REFS) ref/ref.png
	$(PYTHON) z0r.py $(W) $(H) $(ZFIRST) $(ZLAST)
swfs: $(SWFS)
ref/$(ZPREFIX)%.png: swf/$(ZPREFIX)%.swf
	$(RUFFLE) -s --frames 1 --width $(W) --height $(H) $< $@
ref/ref.png:
	$(CONVERT) -size $(W)x$(H) "canvas:#222" $@
swf/$(ZPREFIX)%.swf:
	curl -L -s -f https://z0r.de/L/$(notdir $@) -o $@

.PRECIOUS: $(SWFS)
.PHONY: all swfs
