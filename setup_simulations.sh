#! /bin/sh
# Clone repo.
# if [ ! -d ".git" ]; then
#   git clone git@gitlab.com:adam.blakey/phd-monolith.git .
# fi

# Make output and image directories if they don't exist.
mkdir -p output
mkdir -p images
mkdir -p images/subplots

# Make build directories.
mkdir -p programs/velocity-transport/.mod
mkdir -p programs/velocity-transport/.obj
mkdir -p programs/evaluate-solution/.mod
mkdir -p programs/evaluate-solution/.obj

# Create the Python virtual environment.
python3.11 -m venv .python3-venv

# Active the virtual environement.
source ./.python3-venv/bin/activate

# Install Python packages.
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
python3 -m pip install -e .