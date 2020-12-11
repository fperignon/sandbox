FROM gricad-registry.univ-grenoble-alpes.fr/ced2019/siconos/debian-buster
RUN env
RUN cd /builds/ced2019/siconos/build; make install ; cp -R /builds/ced2019/siconos/install-siconos /root/install-siconos
ENV SICONOS_INSTALL_DIR=/root/install-siconos PATH=/root/install-siconos/bin/:$PATH
RUN apt clean && apt autoremove
