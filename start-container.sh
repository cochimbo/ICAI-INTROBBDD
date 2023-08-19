#!/bin/bash
# Create a Docker volume named ICAIDATA
docker volume create ICAIDATA
# Create a directory for your workspace in your user profile folder
mkdir -p "$HOME/workspace"
# Run a Docker container with volume and directory mounts
docker run --name practicasbbdd -v "ICAIDATA:/var/lib/mysql" -v "$HOME/workspace:/workspace" cochimbo/introbbddicade
