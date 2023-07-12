LIBNAME := Helix

.SUFFIXES:

.PHONY: default config clean clean-dep clean-ml distclean clean-doc tags doc install-doc install-dist install-deps targz graph wc print-unused  all run test update-vellvm benchmark timing wc dep-versions

# parse the -j flag if present, set jobs to 1 oterwise
JFLAG=$(patsubst -j%,%,$(filter -j%,$(MFLAGS)))
JOBS=$(if $(JFLAG),$(JFLAG),4)

MAKECOQ := +$(MAKE) -r -f Makefile.coq

VDIR := coq

VFILES := $(shell find $(VDIR) -name \*.v | grep -v .\#)
VOFILES = $(VFILES:.v=.vo)
MYVFILES := $(filter-out $(LIBVFILES), $(VFILES))

COQINCLUDES=`grep '\-R' _CoqProject` -R $(EXTRACTDIR) Extract
COQEXEC=coqtop -q -w none $(COQINCLUDES) -batch -load-vernac-source

COQ_VERSION=8.13.2

default: all

all: .depend Makefile.coq 
	$(MAKECOQ)


.depend: $(VFILES) 
	@echo "Analyzing Coq dependencies in" $(VFILES)
	coqdep -f _CoqProject $^ > .depend


# Exclude some proofs from list of files required to run tests
# This allows us to run unit tests even if sources just partially compile
TESTVOFILES = $(filter-out coq/DynWin/DynWinProofs.vo  coq/LLVMGen/Vellvm_Utils.v, $(VOFILES))


install-deps:
	opam install --jobs=$(JOBS) --deps-only .

config Makefile.coq: _CoqProject Makefile
	coq_makefile -f _CoqProject $(VFILES) -o Makefile.coq

clean: 
	rm -f `find . -name \*~`
	-$(MAKECOQ) clean
	rm -rf `find . -name .coq-native -o -name .\*.aux -o -name \*.time -o -name \*.cache -o -name \*.timing`
	rm -f graph.dpd graph.dot graph.svg
	rm -f moddep.dot moddep.svg

clean-dep:
	rm -f .depend
	rm -f `find . -name \*.v.d`

distclean: clean clean-dep clean-doc clean-vellvm
	rm -f Makefile.coq Makefile.coq.conf

clean-doc:
	rm -f doc/$(LIBNAME).* doc/index.html doc/main.html coqdoc.sty coqdoc.css

doc: $(MYVFILES)
	coqdoc --html  --utf8 -d doc -R . $(LIBNAME) $(MYVFILES)
	coqdoc --latex --utf8 -d doc -R . $(LIBNAME) $(MYVFILES)

depgraph.vcmd: $(VOFILES)
	rm -f depgraph.vcmd
	echo "Require dpdgraph.dpdgraph." > depgraph.vcmd
	echo "Require $(MYVFILES:.v=)." >> depgraph.vcmd
	echo "Print FileDependGraph $(MYVFILES:.v=)." >> depgraph.vcmd
	sed -ie 's/coq\///g; s/\//./g' depgraph.vcmd


%.vo: %.v
	$(MAKECOQ) $@

%:
	$(MAKECOQ) $@

moddep.dot: Makefile
	coqdep -R . $(LIBNAME) $(MYVFILES)  -dumpgraphbox moddep.dot

moddep.svg: moddep.dot Makefile
	dot -Tsvg moddep.dot > moddep.svg

timing: .depend Makefile.coq
	$(MAKECOQ) TIMING=1

vellvm:
	make -j 1 -C lib/vellvm/src

clean-vellvm:
	rm -f `find lib/vellvm/ -name \*.vo`
	make -C lib/vellvm/src clean
	make -C lib/vellvm/lib/QuickChick clean
	make -C lib/vellvm/lib/flocq-quickchick clean


benchmark: timing
	find .  -name "*.v.timing" -exec awk -F " " \
		'{print $$6 "s @" $$2 "-" $$4 " " $$5 " " FILENAME}' \
		{} \; | sort -n | column -t | tail -n 50
