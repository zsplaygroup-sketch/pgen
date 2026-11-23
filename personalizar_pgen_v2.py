from pathlib import Path
import sys
root=Path(sys.argv[1]) if len(sys.argv)>1 else Path('.')
p=root/'ps2/gui/gui.cpp'
if not p.is_file():
    raise SystemExit('ERRO: execute informando a pasta raiz do codigo-fonte PGEN (deve conter ps2/gui/gui.cpp).')
s=p.read_text(encoding='latin1')
changes=[
 ('"Rom List", "Options", "Save Manager", "Credits", "Exit"', '"Jogos", "Opcoes", "Saves", "Creditos", "Sair"'),
 ('"Main Menu"', '"SD CEARA GAMES"'),
 ('"Loading..."', '"Carregando..."'),
 ('"    PGEN 1.5.1s by Sjeep and others (see credits)"\n\t"readapted by AKuHAK"', '"    SD CEARA GAMES - Seu Bairro Joga Aqui - PGEN por Sjeep e colaboradores"'),
]
missing=[a for a,b in changes if a not in s and b not in s]
if missing:
    raise SystemExit('ERRO: codigo-fonte diferente do esperado; nenhuma alteracao realizada. Trechos ausentes: '+repr(missing))
backup=p.with_name('gui.cpp.original')
if not backup.exists(): backup.write_bytes(p.read_bytes())
for old,new in changes:
    if old in s:
        s=s.replace(old,new,1)
        print('OK:',old[:55])
    else: print('JA APLICADO:',new[:55])
p.write_text(s,encoding='latin1')
print('Concluido: codigo da interface alterado. Nenhum ELF compilado. Video PAL/NTSC preservado.')
