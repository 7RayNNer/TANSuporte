# TAN! Suporte

Cliente de acesso remoto da TAN!, derivado do [RustDesk](https://github.com/rustdesk/rustdesk) 1.5.0.

## Branches e remotos

- `tan`: nossa variante (todo o trabalho vai aqui).
- `upstream`: remoto do RustDesk oficial, para puxar atualizações (`git fetch upstream --tags`).
- `libs/hbb_common` foi incorporado ao repositório (era submódulo) porque o nome e o servidor padrão moram nele.

## O que foi personalizado

| O quê | Onde |
|---|---|
| Nome interno `TANSuporte` (pasta de instalação, serviço, registro, `tansuporte://`) | `libs/hbb_common/src/config.rs` (`APP_NAME`, `ORG`) |
| Nome exibido "TAN! Suporte" (título da janela) | `flutter/lib/common.dart` (`getWindowName`), `flutter/windows/runner/main.cpp`, `src/core_main.rs` |
| Servidor e chave fixos no build | `config.rs` lê `RENDEZVOUS_SERVER` e `RS_PUB_KEY` em tempo de compilação |
| Cores (azul `#1E3A8A`, ID em laranja `#F26522`) | `flutter/lib/common.dart` (`MyTheme`) |
| Metadados do exe (ProductName, descrição, copyright) | `Cargo.toml`, `libs/portable/Cargo.toml`, `flutter/windows/runner/Runner.rc` |
| Ícones | gerados por `tan/gerar_icones.py` a partir de `tan/marca/` |

O nome interno não tem espaço nem "!" de propósito: ele vira esquema de URI, nome de serviço do Windows e nome do exe instalado.

## Trocar a logo

Substitua os dois arquivos e faça commit:

- `tan/marca/icone.png`: quadrado, 1024x1024, fundo transparente ou com o quadrado azul.
- `tan/marca/icone.svg`: a mesma arte em vetor (aparece na tela inicial do app).

Hoje: balão de chat "T!" (`icone-original.png` é o arquivo recebido, 1254px com cantos pretos; `icone.png` é o recorte com cantos transparentes; `icone.svg` embute o PNG).

## Gerar o exe

O build roda no GitHub Actions (`.github/workflows/tan-windows.yml`), porque montar o ambiente local
(Rust 1.75, LLVM 15, vcpkg, Flutter 3.24.5 com engine do RustDesk) é pesado. Leva por volta de 1 hora na primeira vez.

1. Suba esta branch para um repositório no GitHub.
2. (Opcional) Em *Settings > Secrets and variables > Actions > Variables*, crie `RENDEZVOUS_SERVER` e `RS_PUB_KEY`.
3. Rode o workflow "TAN! Suporte - Windows" (aba Actions, *Run workflow*) ou crie uma tag `tan-v1.0.0`.
4. Baixe o artefato `tan-suporte-windows-x64` (exe único) ou `tan-suporte-windows-x64-pasta` (pasta solta).

Com tag `tan-v*`, o exe também é publicado como Release.

## Servidor próprio

Sem `RENDEZVOUS_SERVER`, o cliente usa o servidor público do RustDesk (funciona, mas é compartilhado e às vezes lento).
Para servidor próprio, sobe-se o `rustdesk-server` (hbbs + hbbr, código aberto) numa VPS, com as portas TCP 21115-21117
e UDP 21116 liberadas, e coloca-se o host e o conteúdo de `id_ed25519.pub` nas variáveis acima.

## Licença

O RustDesk é AGPL-3.0. Distribuir este exe a clientes obriga a oferecer o código-fonte da variante
(um repositório público basta). Não remova o aviso "baseado no RustDesk" dos metadados.
