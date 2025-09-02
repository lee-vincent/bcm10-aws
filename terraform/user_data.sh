#!/usr/bin/env bash
set -eux

# Detect common distros and prep for Ansible
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    rocky|rhel|almalinux|centos)
      dnf -y update || true
      dnf -y install python3 python3-pip tar unzip vim git curl || true
      ;;
    ubuntu|debian)
      apt-get update -y
      apt-get install -y python3 python3-pip tar unzip vim git curl
      ;;
    suse|sles)
      zypper -n refresh || true
      zypper -n in python3 python3-pip tar unzip vim git curl || true
      ;;
  esac
fi

# Create ansible-friendly user symlinks if needed
if ! command -v python &>/dev/null; then
  ln -sf /usr/bin/python3 /usr/local/bin/python || true
  ln -sf /usr/bin/python3 /usr/bin/python || true
fi

# Optional: harden SSH (leave default for demo)
