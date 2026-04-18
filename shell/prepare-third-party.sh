#!/bin/bash
set -euo pipefail

WORKDIR="${1:-$(pwd)}"
PKG_DIR="$WORKDIR/package/custom"
mkdir -p "$PKG_DIR"

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"
  echo "==> sync $repo_url -> $target_dir"
  rm -rf "$target_dir"
  git clone --depth=1 "$repo_url" "$target_dir"
}

clone_or_update "https://github.com/timsaya/openwrt-bandix" "$PKG_DIR/openwrt-bandix"
BANDIX_LUCI_REF="${BANDIX_LUCI_REF:-latest}"
clone_or_update "https://github.com/timsaya/luci-app-bandix" "$PKG_DIR/luci-app-bandix"
if [ "$BANDIX_LUCI_REF" != "latest" ]; then
  ( cd "$PKG_DIR/luci-app-bandix" && git fetch --depth=1 origin "refs/tags/${BANDIX_LUCI_REF}:refs/tags/${BANDIX_LUCI_REF}" && git checkout -q "${BANDIX_LUCI_REF}" )
fi

clone_or_update "https://github.com/sirpdboy/luci-app-taskplan" "$PKG_DIR/luci-app-taskplan-src"

# 调整 taskplan 菜单：从 管控 挪到 服务
TASKPLAN_MENU="$PKG_DIR/luci-app-taskplan-src/luci-app-taskplan/root/usr/share/luci/menu.d/luci-app-taskplan.json"
if [ -f "$TASKPLAN_MENU" ]; then
  sed -i "s#admin/control#admin/services#g" "$TASKPLAN_MENU"
fi
