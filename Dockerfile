FROM owlbarn/owl:latest
USER root

# prepare dependency

RUN apt-get update && apt-get install -y pandoc
RUN cd /home/opam/opam-repository && git pull --quiet origin master
RUN opam install dune=2.0.1

# install owl-tutorials

WORKDIR /home/opam/owl_tutorials
COPY . ${WORKDIR}

# RUN sudo chown -R opam /home/opam/src
RUN opam exec -- dune build @site
RUN opam exec -- dune runtest

ENTRYPOINT /bin/bash
