#!/usr/bin/env bash
set -euo pipefail
if [[ ! -f ps2/gui/gui.cpp ]]; then echo 'Execute na raiz do repositorio PGEN'; exit 1; fi
python3 personalizar_pgen_v2.py .
: "${PS2DEV:?PS2DEV precisa estar configurado}"
: "${PS2SDK:?PS2SDK precisa estar configurado}"
command -v ee-g++ >/dev/null || { echo 'Compilador ee-g++ nao encontrado'; exit 1; }
make -C ps2
mkdir -p dist
cp ps2/pgen.elf dist/PGEN-SD-CEARA-TESTE.ELF
sha256sum dist/PGEN-SD-CEARA-TESTE.ELF
