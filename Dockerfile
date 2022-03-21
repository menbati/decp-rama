FROM python:3.9-slim
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
  && apt-get install -y xsltproc libxml2-utils git build-essential curl zip unzip wget python3-venv python3-pip lftp autoconf automake make libtool flex --no-install-recommends \
  && apt-get clean && rm -rf /var/cache/apt
WORKDIR /deps
#RUN git clone https://github.com/edsu/json2xml.git
RUN git clone https://github.com/Cheedoong/xml2json.git
RUN git clone https://github.com/OpenDataServices/flatten-tool.git

# install jq manually because of performance issues in release 1.6
RUN mkdir jq
RUN git clone https://github.com/stedolan/jq.git jq/repo
RUN cd /deps/jq/repo && git checkout a9f97e9e61a910a374a5d768244e8ad63f407d3e && git submodule update --init \
  && autoreconf -fi && ./configure --with-oniguruma=builtin --disable-maintainer-mode --prefix=$PWD/.. \
  && make && make install
RUN chmod +x jq

RUN cd /deps/xml2json && make
RUN cd /deps/flatten-tool
RUN python3 -m venv .ve
#RUN source .ve/bin/activate
RUN ["/bin/bash", "-c", "source .ve/bin/activate"]
RUN pip install json2xml
#RUN pip3 install -r requirements.txt
ENV PATH="$PATH:/deps:/deps/xml2json:/deps/jq/bin"
