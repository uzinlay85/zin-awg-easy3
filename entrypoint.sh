#!/bin/sh
# AWG 3.1 needs amneziawg kernel module 3.0+; an older one accepts the
# interface but rejects the config, and awg-quick will not fall back once
# ip link add has succeeded.
if ip link add awgprobe type amneziawg 2>/dev/null; then
  KMOD_VERSION=$(cat /sys/module/amneziawg/version 2>/dev/null)
  ip link delete awgprobe 2>/dev/null
  case "$KMOD_VERSION" in
    3.*|[4-9].*|[1-9][0-9].*) ;;
    *) echo "amneziawg kernel module ${KMOD_VERSION:-unknown} predates AWG 3.1, using userspace amneziawg-go"
       export WG_FORCE_USERSPACE=1 ;;
  esac
fi

exec /usr/bin/dumb-init node server.js