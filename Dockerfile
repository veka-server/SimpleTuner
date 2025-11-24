# SimpleTuner needs CU141
# FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

ARG PYTHON_VERSION=3.11

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# ----------------------------
# 🔥 SYSTEM PACKAGES + CLEANUP
# ----------------------------
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        git-lfs \
        htop \
        inotify-tools \
        iputils-ping \
        less \
        libgl1-mesa-glx \
        libsm6 \
        libxext6 \
        libopenmpi-dev \
        net-tools \
        nvtop \
        openmpi-bin \
        openssh-client \
        openssh-server \
        p7zip-full \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-venv \
        rsync \
        tmux \
        tldr \
        unzip \
        vim \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*

# ----------------------------
# 🔥 CONFIG GIT
# ----------------------------
RUN git config --global credential.helper store && git lfs install

# ----------------------------
# 🔥 CREATE VENV + CLEAN CACHE
# ----------------------------
RUN python${PYTHON_VERSION} -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    pip cache purge

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

EXPOSE 22/tcp

ENV HF_HOME=/workspace/huggingface
ENV SIMPLETUNER_PLATFORM=cuda

# ------------------------------------------------
# 🔥 INSTALL HUGGINGFACE + WANDB + CLEAN CACHE
# ------------------------------------------------
RUN pip install --no-cache-dir "huggingface_hub[cli]" wandb && \
    pip cache purge && \
    rm -rf /root/.cache/huggingface/*

# ------------------------------------------------
# 🔥 MPI BINDINGS + CLEAN
# ------------------------------------------------
RUN pip install --no-cache-dir mpi4py && \
    pip cache purge

# ------------------------------------------------
# 🔥 SIMPLETUNER + CLEAN
# ------------------------------------------------
RUN pip install --no-cache-dir simpletuner && \
    pip cache purge && \
    rm -rf /root/.cache/*

COPY --chmod=755 docker-start.sh /start.sh

WORKDIR /workspace

ENTRYPOINT [ "/start.sh" ]
