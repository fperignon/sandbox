FROM gricad-registry.univ-grenoble-alpes.fr/ced2019/siconos/sources/ubuntu20.04
RUN apt update  && apt install -y -qq \
        liboce-foundation-dev \
        liboce-modeling-dev \
        liboce-ocaf-dev \
        liboce-visualization-dev && apt clean && apt autoremove
WORKDIR /home
COPY ci_gitlab/dockerfiles/install_oce.sh /home
ENV CI_PROJECT_DIR /home 
RUN sh /home/install_oce.sh
ENV PYTHONPATH /home/install/site-packages
