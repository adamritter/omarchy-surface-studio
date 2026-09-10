#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
for shader in studio/gradient.frag studio/shadow.frag; do
  /usr/lib/qt6/bin/qsb --glsl '100 es,120,150' --hlsl 50 --msl 12 -o "$shader.qsb" "$shader"
done
