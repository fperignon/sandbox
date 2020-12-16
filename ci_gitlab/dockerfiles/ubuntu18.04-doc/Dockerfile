FROM gricad-registry.univ-grenoble-alpes.fr/ced2019/siconos/sources/ubuntu18.04-oce
RUN apt update  && apt install -y -qq \
        graphviz && apt clean && apt autoremove&& rm -rf /var/lib/apt/lists/*
WORKDIR /home
COPY requirements4doc.txt .
RUN pip3 install -U -r /home/requirements4doc.txt
ENV LANG C.UTF-8 # Required, else doxy2swig fails!
RUN pip3 install git+https://github.com/sphinx-contrib/youtube.git
