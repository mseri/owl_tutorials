.PHONY: all clean dep publish promote test test-all docker depext \
	duniverse-init duniverse-upgrade all-old

DUNIVERSE ?= duniverse

DEPS =\
async \
base \
cmdliner \
core \
ctypes \
ctypes-foreign \
fmt \
jupyter \
lambdasoup \
mdx \
ocaml-compiler-libs \
owl-base \
owl \
owl-top \
owl-symbolic \
owl-plplot \
ppx_jane \
re \
sexp_pretty \
textwrap \
yojson

# these do not exist in opam-repository yet
DUNIVERSE_SPECIFIC_DEPS = # tls-lwt

all:
	-docker run -t -d --name owl_tutorials_builder owlbarn/owl_tutorials:latest
	docker cp . owl_tutorials_builder:/home/opam/owl_tutorials_local
	docker exec -it owl_tutorials_builder bash -c 'cd /home/opam/owl_tutorials_local && eval `opam env` && make compile'
	docker cp owl_tutorials_builder:/home/opam/owl_tutorials_local/book .
	docker cp owl_tutorials_builder:/home/opam/owl_tutorials_local/docs .
	docker cp owl_tutorials_builder:/home/opam/owl_tutorials_local/static .

docker:
	docker build -t owlbarn/owl_tutorials:latest .

all-old:
	@dune build @site @pdf
	@echo The site and the pdf have been generated in _build/default/static/

test:
	dune runtest

test-all:
	dune build @runtest-all

dep:
	dune exec -- otb-dep

promote:
	dune promote

clean:
	dune clean

depext:
	opam depext -y $(DEPS)

duniverse-init:
	$(DUNIVERSE) init \
	    --pin owl-base,https://github.com/owlbarn/owl.git,master \
		--pin owl,https://github.com/owlbarn/owl.git,master \
		--pin owl-symbolic,https://github.com/owlbarn/owl_symbolic.git,master \
		--pin mdx,https://github.com/realworldocaml/mdx.git,master \
		otb \
		$(DEPS) $(DUNIVERSE_SPECIFIC_DEPS)

duniverse-upgrade: duniverse-init
	$(DUNIVERSE) pull --no-cache