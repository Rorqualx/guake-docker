# Use Ubuntu as base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required for building and running Guake
RUN apt-get update && apt-get install --no-install-recommends -y \
    # Core build dependencies
    make \
    pandoc \
    gettext \
    gsettings-desktop-schemas \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-setuptools-scm \
    git \
    # Runtime dependencies
    gir1.2-keybinder-3.0 \
    gir1.2-notify-0.7 \
    gir1.2-vte-2.91 \
    gir1.2-wnck-3.0 \
    libkeybinder-3.0-0 \
    libutempter0 \
    python3-cairo \
    python3-dbus \
    python3-gi \
    libgirepository1.0-dev \
    glib-2.0-dev \
    # X11 dependencies
    xvfb \
    x11-utils \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy the source
COPY . .

# Create a temporary setup.py without setuptools_scm
RUN echo '\
from setuptools import setup\n\
setup(\n\
    name="guake",\n\
    version="3.9.0",\n\
    packages=["guake"],\n\
    install_requires=[\n\
        "pbr",\n\
        "wheel",\n\
    ],\n\
)\n\
' > setup.py

# Install required packages first
RUN pip3 install pbr wheel

# Install the package
RUN pip3 install --no-deps .

# Install schemas and compile them
RUN mkdir -p /usr/share/glib-2.0/schemas && \
    cp guake/data/org.guake.gschema.xml /usr/share/glib-2.0/schemas/ && \
    glib-compile-schemas /usr/share/glib-2.0/schemas/

# Install data files
RUN mkdir -p /usr/share/guake && \
    cp -r guake/data/* /usr/share/guake/

# Create required directories
RUN mkdir -p /etc/guake /usr/share/pixmaps

# Create a script to start Guake with Xvfb
RUN echo '#!/bin/bash\n\
export XDG_DATA_DIRS=/usr/share:/usr/local/share:/usr/share/guake\n\
export GSETTINGS_SCHEMA_DIR=/usr/share/glib-2.0/schemas\n\
xvfb-run --server-args="-screen 0 1024x768x24" guake' > /start-guake.sh && \
    chmod +x /start-guake.sh

# Set the entry point
ENTRYPOINT ["/start-guake.sh"]
