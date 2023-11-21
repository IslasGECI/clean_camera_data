FROM islasgeci/base:1.0.0
COPY . /workdir
RUN make install
