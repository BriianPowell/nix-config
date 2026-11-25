#!/usr/bin/env bash
# Desk monitor layout. Regenerate when display IDs change: displayplacer list
set -euo pipefail
exec displayplacer \
  "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:2056x1329 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
  "id:EA121D52-37E7-494B-846B-E4883A08C049 res:2560x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(5496,0) degree:0" \
  "id:22572CD6-50D0-4A20-947F-3DDEB101C6ED res:3440x1440 hz:100 color_depth:8 enabled:true scaling:off origin:(2056,0) degree:0" \
  "id:BAF3A479-B2BD-4ECF-8359-F6673EC3BF89 res:2560x1440 hz:60 color_depth:8 enabled:true scaling:off origin:(8056,0) degree:0"
