FROM islasgeci/base:latest
COPY . /workdir
WORKDIR /workdir

RUN make install
