FROM jupyter/base-notebook:9089b66a9813
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

USER root
RUN apt-get update -y && \
    apt-get install -y nodejs wget git && \
    apt-get install -y build-essential

RUN install -o jovyan -g users -d /notebooks /opt/omero

# switch user
USER jovyan

# RISE: "Live" Reveal.js Jupyter/IPython Slideshow Extension
# https://github.com/damianavila/RISE
RUN conda install --quiet --yes -c damianavila82 rise

# Display resource usage in notebooks https://github.com/yuvipanda/nbresuse
RUN pip install https://github.com/IDR/nbresuse/archive/0.1.0-idr.zip && \
    jupyter serverextension enable --py nbresuse && \
    jupyter nbextension install --py --user nbresuse && \
    jupyter nbextension enable --py --user nbresuse

# create a python2 environment (for OMERO-PY compatibility)
ADD environment-python2.yml .
RUN conda env create -n python2 -f environment-python2.yml

RUN mkdir -p /home/jovyan/.local/share/jupyter/kernels/python2 && \
    sed 's/Python 2/OMERO Python 2/' \
        /opt/conda/envs/python2/share/jupyter/kernels/python2/kernel.json > \
        /home/jovyan/.local/share/jupyter/kernels/python2/kernel.json

# switch user and working directory to /notebooks folder
USER jovyan
WORKDIR /notebooks
RUN git clone -b 0.6.0 https://github.com/IDR/idr-notebooks /notebooks

# Downgrade version of jupyterhub
RUN pip install jupyterhub==0.7.2

# Autodetects jupyterhub and standalone modes
CMD ["start-notebook.sh"]
