FROM islasgeci/base:22.04
COPY . /workdir

RUN make install
