#!/bin/bash

##### SET FOLLOWING VARS #####
CONDA_DIR="/home/$USER/src/miniconda3"
SERVER_ADDR="192.168.0.187"
SERVER_PORT=7862
###### END OF VARIABLES ######


# source base conda env in this script's subshell
# https://github.com/conda/conda/issues/7980
source $CONDA_DIR/etc/profile.d/conda.sh

# set working dir to this script's location:
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INSTALL_DIR="$SCRIPT_DIR/Paints-UNDO"
CONDA_ENV_DIR="$SCRIPT_DIR/conda_env"

available() { command -v $1 >/dev/null; }

cd $SCRIPT_DIR

# check if miniconda already installed
if ! available conda; then
    echo "miniconda is not yet installed. Install it first."
    exit 0
fi

# check if conda env already exists, create if not yet done
if [ ! -d "$CONDA_ENV_DIR" ]; then
    conda create --no-shortcuts -y -k --prefix "$CONDA_ENV_DIR" python=3.10
fi

# confirm if conda env is actually created
if [ ! -f "$CONDA_ENV_DIR/bin/python" ]; then
    echo "python is not found in $CONDA_ENV_DIR/bin"
    echo "exiting."
    exit 0
fi

# activate conda env
conda activate $CONDA_ENV_DIR || echo "Miniconda hook not found."

# check if install dir already exists
if [ ! -d "$INSTALL_DIR" ]; then
    git clone https://github.com/lllyasviel/Paints-UNDO.git
    cd Paints-UNDO
    pip install xformers
    pip install -r requirements.txt
    sed -i -e "s/server_name='0.0.0.0'/ /" gradio_app.py # need to remove this so we can set via env var below
fi

cd $SCRIPT_DIR/Paints-UNDO

# launch
export GRADIO_SERVER_NAME=$SERVER_ADDR
export GRADIO_SERVER_PORT=$SERVER_PORT
python gradio_app.py