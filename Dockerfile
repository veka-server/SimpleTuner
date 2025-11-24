FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive

# ---- System deps ----
RUN apt-get update -y && apt-get install -y --no-install-recommends \
        git \
        git-lfs \
        ffmpeg \
        libgl1-mesa-glx \
        libsm6 \
        libxext6 \
    && rm -rf /var/lib/apt/lists/*

RUN git lfs install

# ---- Pip deps ----
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        "huggingface_hub[cli]" \
        wandb \
        mpi4py \
        simpletuner

WORKDIR /workspace

COPY --chmod=755 docker-start.sh /start.sh
ENTRYPOINT ["/start.sh"]
