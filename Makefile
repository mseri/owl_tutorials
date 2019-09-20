.PHONY: all clean dep publish promote test test-all docker depext push depext vendor

all: test
	@dune build @site
	@echo Site has been generated in _build/default/static/

test: tool
	@dune build @runtest
	@dune exec -- otb-dep $(CURDIR)

test-all:
	@dune build @runtest-all

tool:
	@dune build @install

clean:
	@dune clean

push:
	git commit -am "editing book ..." && \
	git push origin `git branch | grep \* | cut -d ' ' -f2`

depext:
	opam depext -y core async ppx_sexp_conv dune toplevel_expect_test patdiff \
		lambdasoup sexp_pretty fmt re mdx ctypes-foreign conf-ncurses eigen owl \
		owl-plplot owl-ode-odepack zarith
	opam install ocp-pp.1.99.19-beta plplot.5.11.0 zarith

vendor:
	duniverse init otb `cat book-pkgs` --pin mdx,https://github.com/Julow/mdx.git,duniverse_mode --pin gp,https://github.com/hennequin-lab/gp.git,master
