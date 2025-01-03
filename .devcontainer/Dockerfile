# ref
# - https://qiita.com/a163236/items/b0dba0d6aa9a18a926e8

# NOTE:
# Using ubuntu:24.10, apt-get install of verilator will get packages that are not executable.
# see https://bugs.launchpad.net/ubuntu/+source/verilator/+bug/2089210
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FROM ubuntu:22.04 as build
RUN apt-get update && apt-get upgrade -y

ENV RISCV=/opt/riscv
ENV PATH=$RISCV/bin:$PATH
ENV LC_ALL=C.UTF-8

RUN apt-get install -y --no-install-recommends \
  ca-certificates \
  ccache \
  mold \
  git autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev \
  gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

RUN git config --global http.version HTTP/1.1

# riscv-gnu-toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain && \
  cd riscv-gnu-toolchain && \
  ./configure --prefix=/opt/riscv && \
  make newlib -j"$(nproc)"

# riscv Spike
RUN apt-get install -y --no-install-recommends device-tree-compiler
RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
  cd riscv-isa-sim && \
  mkdir build && \
  cd build && \
  ../configure --prefix=$RISCV && \
  make -j"$(nproc)" && \
  make install

# riscv proxy kernel
RUN git clone https://github.com/riscv/riscv-pk && \
  cd riscv-pk && \
  mkdir build && \
  cd build && \
  ../configure --prefix=$RISCV --host=riscv64-unknown-elf && \
  make -j"$(nproc)" && \
  make install

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FROM ubuntu:22.04 as development

ARG VERYLUP_VERSION=0.1.4

# build-essential: gcc, make
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  ccache \
  device-tree-compiler  \
  git \
  gnupg2 \
  mold \
  python3 \
  unzip \
  verilator \
  vim \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install verylup(deps: wget, unzip)
RUN wget -q https://github.com/veryl-lang/verylup/releases/download/v${VERYLUP_VERSION}/verylup-x86_64-linux.zip \
  && unzip verylup-x86_64-linux.zip \
  && mv verylup /bin/verylup \
  && chmod +x /bin/verylup \
  && rm verylup-x86_64-linux.zip

RUN verylup setup && verylup update

ENV RISCV=/opt/riscv
ENV PATH=$RISCV/bin:$PATH
# NOTE: Language settings are required to use perl.
ENV LC_ALL=C.UTF-8

WORKDIR /home
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
COPY --from=build /opt/riscv/ /opt/riscv
