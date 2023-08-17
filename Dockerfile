FROM python:3.10-slim

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Global variables for pretrainer
ENV NCCL_DEBUG="INFO"
ENV OMPI_MCA_opal_cuda_support="true"
ENV CONDA_OVERRIDE_GLIBC="2.56"
ENV RANDOM_SEED=0
ENV TORCH_SEED=42


# Copy necessary files
COPY requirements.txt .
COPY Geneformer /Geneformer
COPY Genecorpus /Genecorpus

# Install pip requirements
RUN pip install --no-cache-dir --upgrade pip
RUN python -m pip install -r requirements.txt
# Install Geneformer
RUN python -m pip install ./Geneformer

WORKDIR /app
COPY . /app

ENV ROOT_DIR="/app"
RUN mkdir -p ${ROOT_DIR}

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "-u", "app.py"]