"""Gera os icones do TAN! Suporte a partir de tan/marca/icone.png e tan/marca/icone.svg.

Roda no CI antes do build (precisa de Pillow) e pode rodar local: python tan/gerar_icones.py
Para trocar a logo, basta substituir os dois arquivos em tan/marca/ (PNG quadrado, de preferencia 1024x1024).
"""
import shutil
from pathlib import Path

from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
MARCA = RAIZ / "tan" / "marca"

ICO_TAMANHOS = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
ICOS = [
    "res/icon.ico",
    "res/tray-icon.ico",
    "flutter/windows/runner/resources/app_icon.ico",
]
# PNGs existentes: mantem o tamanho de cada um.
PNGS = [
    "res/icon.png",
    "res/32x32.png",
    "res/64x64.png",
    "res/128x128.png",
    "res/128x128@2x.png",
    "res/mac-icon.png",
    "flutter/assets/icon.png",
]


def main():
    origem = Image.open(MARCA / "icone.png").convert("RGBA")
    if origem.width != origem.height:
        raise SystemExit(f"icone.png precisa ser quadrado, veio {origem.size}")

    for rel in ICOS:
        destino = RAIZ / rel
        origem.save(destino, format="ICO", sizes=ICO_TAMANHOS)
        print("ico", rel)

    for rel in PNGS:
        destino = RAIZ / rel
        tamanho = Image.open(destino).size if destino.exists() else (256, 256)
        origem.resize(tamanho, Image.LANCZOS).save(destino)
        print("png", rel, tamanho)

    shutil.copyfile(MARCA / "icone.svg", RAIZ / "flutter/assets/icon.svg")
    print("svg flutter/assets/icon.svg")


if __name__ == "__main__":
    main()
