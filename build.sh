#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f ps2/gui/gui.cpp ]]; then
  echo 'ERRO: execute na raiz do repositorio PGEN.' >&2
  exit 1
fi

python3 personalizar_pgen_v2.py .

: "${PS2DEV:?PS2DEV nao configurado}"
: "${PS2SDK:?PS2SDK nao configurado}"

# Compatibilidade com os nomes de ferramentas usados no PGEN original.
# Os links sao temporarios e nao alteram os Makefiles do projeto.
TOOL_PREFIX=mips64r5900el-ps2-elf-
COMPAT_DIR="$(mktemp -d)"
trap 'rm -rf "$COMPAT_DIR"' EXIT
for tool in gcc g++ cpp ld as ar ranlib strip objcopy objdump nm; do
  target="$(command -v "${TOOL_PREFIX}${tool}" || true)"
  if [[ -n "$target" ]]; then
    ln -s "$target" "$COMPAT_DIR/ee-${tool}"
  fi
done
export PATH="$COMPAT_DIR:$PATH"

command -v ee-g++ >/dev/null || { echo 'ERRO: compilador PS2 nao encontrado'; exit 1; }
command -v ee-strip >/dev/null || { echo 'ERRO: ee-strip nao encontrado'; exit 1; }

echo '=== Versao do compilador ==='
ee-g++ --version | head -n 1
echo '=== Verificando ferramentas auxiliares ==='
for tool in ps2-packer dvp-as iop-gcc; do
  command -v "$tool" || echo "AVISO: $tool nao encontrado (pode ser necessario no build)"
done

echo '=== Compilando PGEN ==='
make -C ps2

mkdir -p dist
if [[ -f ps2/pgen.elf ]]; then
  cp ps2/pgen.elf dist/PGEN-SD-CEARA-TESTE.ELF
elif [[ -f ps2/pgen-packed.elf ]]; then
  cp ps2/pgen-packed.elf dist/PGEN-SD-CEARA-TESTE.ELF
else
  echo 'ERRO: make terminou sem gerar ELF.' >&2
  exit 1
fi
sha256sum dist/PGEN-SD-CEARA-TESTE.ELF
