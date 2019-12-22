FROM owlbarn/owl:latest
USER root

WORKDIR /home/opam/owl_tutorials
COPY . ${WORKDIR}
RUN apt-get update && apt-get install -y pandoc
RUN opam install core async lambdasoup re sexp_pretty ppx_jane mdx

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

ENTRYPOINT /bin/bash
