CURL    ?= curl
PYTHON  ?= python3
CONVERT ?= convert
RUFFLE  ?= ~/src/ruffle/target/debug/exporter

W       ?= 128
H       ?= 80

ZPREFIX = z0r-de_
ZFIRST  = 0
ZLAST   = 7911

# https://github.com/ruffle-rs/ruffle/issues/720
EXCLUDE = 1722 1724 1966 2021 2279 3335 3536 3845 5362 5586 6138 7765 7766

# 404
EXCLUDE += 2381 7546

# Error decompressing SWF, may be corrupt: Adler32 checksum mismatched
EXCLUDE += 2674

# MP4 file
EXCLUDE += 3099

# LZMA unsupported in ruffle
EXCLUDE += 4399 6858 6975 7101 7144 7242 7246 7293 7522 7673 7758

# Error decompressing SWF, may be corrupt: failed to fill whole buffer
EXCLUDE += 6969

ZLIST = $(filter-out $(EXCLUDE),$(shell seq $(ZFIRST) $(ZLAST)))
REFS  = $(addsuffix .png,$(addprefix ref/$(ZPREFIX),$(ZLIST)))

all: $(REFS) ref/ref.png
	$(PYTHON) z0r.py $(W) $(H) $(ZFIRST) $(ZLAST)
ref/$(ZPREFIX)%.png: swf/$(ZPREFIX)%.swf
	$(RUFFLE) -s --frames 1 --width $(W) --height $(H) $< $@
ref/ref.png:
	$(CONVERT) -size $(W)x$(H) "canvas:#222" $@
swf/%.swf:
	curl -L -s -f https://z0r.de/L/$(notdir $@) -o $@

.PHONY: all
