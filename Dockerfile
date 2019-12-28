FROM owlbarn/owl:latest
USER root

# prepare dependency

RUN apt-get update && apt-get install -y pandoc
RUN cd /home/opam/opam-repository && git pull --quiet origin master
RUN opam install core async lambdasoup re sexp_pretty ppx_jane mdx

# install owl-symbolic

RUN opam update -q && opam pin --dev-repo owl-symbolic

# install owl-tutorials

WORKDIR /home/opam/owl_tutorials
COPY . ${WORKDIR}

ENTRYPOINT /bin/bash

# # install non-OCaml dependencies
# COPY Makefile /home/opam/src/.
# RUN make depext
# RUN opam install dune=1.11.3

# #install pandoc
# WORKDIR /tmp
# RUN curl -OL https://github.com/jgm/pandoc/releases/download/2.1.3/pandoc-2.1.3-1-amd64.deb && sudo dpkg -i pandoc-2.1.3-1-amd64.deb
# WORKDIR /home/opam/src

# # compile the project
# COPY . /home/opam/src/
# RUN sudo chown -R opam /home/opam/src
# RUN opam exec -- make
# RUN opam exec -- make test
