FROM gricad-registry.univ-grenoble-alpes.fr/nonsmooth/siconos/sources/ubuntu18.04
RUN apt update  && apt install -y -qq \
    libopenmpi-dev \
    libparmetis-dev \
    libptscotch-dev \
    openssh-client \
    libmumps-dev
RUN python3 -m pip install mpi4py packaging
RUN apt clean && apt autoremove
