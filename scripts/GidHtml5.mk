.PHONY: html5.clean html5.libs html5.install html5

HTML5_PLUGINS=$(PLUGINS_HTML5)

export EMSDK_PREFIX
export CRUNCHME
export HTML5_PLUGINS
export PROFILING
export DEBUG

EMWAT=wasm2wat.exe
export $(EMWAT)


html5.setup:
	cd emscripten; $(MAKE) setup

html5.init:
	cd emscripten; $(MAKE) init
	
html5.clean:
	cd emscripten; $(MAKE) $(MAKEJOBS) clean plugins.clean

html5.main:  
	cd emscripten; $(MAKE) $(MAKEJOBS) main

html5.libs: versioning 
	cd emscripten; $(MAKE) $(MAKEJOBS)

%.html5plugin:
	cd emscripten; $(MAKE) $*.plugin

%.html5plugin.clean:
	cd emscripten; $(MAKE) $*.plugin.clean
	
html5.template: html5.libs
	cp -r emscripten/Build/Html5 $(RELEASE)/Templates
	for p in $(HTML5_PLUGINS); do rm -f $(RELEASE)/All\ Plugins/$$p/bin/Html5; mkdir -p $(RELEASE)/All\ Plugins/$$p/bin/Html5; cp plugins/$$p/source/emscripten/Build/Html/* $(RELEASE)/All\ Plugins/$$p/bin/Html5; done	

html5.player: html5.libs
	mkdir -p $(RELEASE)/Players
	cp -r emscripten/Build/Html5/Html5 $(RELEASE)/Players
	#cp -r emscripten/Build/Html5/Jasm/* $(RELEASE)/Players/Html5
	for p in $(HTML5_PLUGINS); do cp plugins/$$p/source/emscripten/Build/Html/* $(RELEASE)/Players/Html5; done
	#sed -e 's/\/\*GIDEROS_DYNLIB_PLUGIN\*\//"EP_Xmp.js", "EP_mp3.js", "luasocket.js", "json.js", "bit.js", "lfs.js", "lsqlite3.js", /' emscripten/Build/Html5/Jasm/index.html >$(RELEASE)/Players/Html5/index.html

html5.install: html5.template html5.player

html5: html5.install

html5.tools: html5.crunchme html5.lzma

CRUNCHME_SRCS=$(addprefix src/liblzg/lib/,checksum decode encode version)
CRUNCHME_SRCS+=$(addprefix src/zlib/,adler32 compress crc32 deflate inftrees trees zutil)
CRUNCHME_SRCS+=$(addprefix src/,crunchme png)

LZMA_SRCS=LzFind LzmaEnc Lzma2Enc lzma

html5.crunchme: $(addprefix emscripten/crunchme-0.4/,$(addsuffix .co,$(CRUNCHME_SRCS)))
	$(CXX) -o $(ROOT)/ui/Tools/crunchme $^

html5.lzma: $(addprefix emscripten/lzma/,$(addsuffix .co,$(LZMA_SRCS)))
	$(CXX) -o $(ROOT)/ui/Tools/lzma $^
	
%.co: %.cpp
	$(CXX) -c -o $@ -D_7ZIP_ST -Iemscripten/crunchme-0.4/src/liblzg/include $< 

%.co: %.c
	$(CC) -c -o $@ -D_7ZIP_ST $<

	