# Dotfiles Style Guide

## Introduction

This repository contains the dotfiles for my personal development environment. It is a collection of configuration files and scripts that I use to customize my development environment. The goal of this repository is to provide a consistent and reproducible development environment across different machines.

## Key Principles

* This script is used in the following enviornments:
  * Debian Bookworm Desktop Machine
  * Debian Bookworm Headless Server
  * Debian Bookworm on WSL2
  * Debian Bookworm in Crostini on Chromebook
  * MacOS M3

* Configuration files are stored in the `stowed-files` directory, then symlinked via the GNU Stow utility.

* Bash scripts should all follow the "Strict Mode" pattern to ensure that they are safe and reliable
