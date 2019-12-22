.PHONY: all clean dep publish promote test test-all docker depext push vendor compile

all: test
	@dune build @site
	@echo Site has been generated in _build/default/static/
	cp -r _build/default/static/* docs/
	git add docs

test: tool
	@dune build @runtest
	@dune exec -- otb-dep $(CURDIR)

test-all:
	@dune build @runtest-all

tool:
	@dune build @install

promote:
	@dune promote

clean:
	@dune clean
	docker stop owl_tutorials_buidler && docker rm owl_tutorials_buidler

push:
	git commit -am "editing book ..." && \
	git push origin `git branch | grep \* | cut -d ' ' -f2`

docker:
	docker build -t owlbarn/owl_tutorials:latest .

compile:
	docker run -t -d --name owl_tutorials_buidler owlbarn/owl_tutorials:latest
	docker cp . owl_tutorials_buidler:/home/opam/owl_tutorials_local
	docker exec -it owl_tutorials_buidler bash -c 'cd /home/opam/owl_tutorials_local && eval `opam env` && make'
	docker cp owl_tutorials_buidler:/home/opam/owl_tutorials_local/docs .

depext:
	opam depext -y core async ppx_sexp_conv dune toplevel_expect_test patdiff \
		lambdasoup sexp_pretty fmt re mdx ctypes-foreign conf-ncurses eigen owl \
		owl-plplot owl-ode-odepack zarith
	opam install ocp-pp.1.99.19-beta plplot.5.11.0 zarith

vendor:
	duniverse init otb `cat book-pkgs` --pin mdx,https://github.com/Julow/mdx.git,duniverse_mode --pin gp,https://github.com/hennequin-lab/gp.git,master
