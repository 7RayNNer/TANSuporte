// TAN! Suporte: configuracoes do tecnico, so o que ele usa. As opcoes sao as mesmas do RustDesk
// (mesmas chaves), so a tela e nossa.
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/pages/desktop_home_page.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/models/platform_model.dart';

class TanConfiguracoes extends StatefulWidget {
  const TanConfiguracoes({Key? key}) : super(key: key);

  @override
  State<TanConfiguracoes> createState() => _TanConfiguracoesState();
}

class _TanConfiguracoesState extends State<TanConfiguracoes> {
  @override
  Widget build(BuildContext context) {
    final tema = MyTheme.getThemeModePreference().toShortString();
    final qualidade = bind.mainGetUserDefaultOption(key: kOptionImageQuality);
    final ajustar =
        bind.mainGetUserDefaultOption(key: kOptionViewStyle) == 'adaptive';
    final abas = mainGetLocalBoolOptionSync(kOptionOpenNewConnInTabs);

    permissao(String rotulo, String chave, {bool ultima = false}) => TanLinha(
          rotulo: rotulo,
          ultima: ultima,
          direita: TanChave(
            valor: mainGetBoolOptionSync(chave),
            onChanged: (v) async {
              await mainSetBoolOption(chave, v);
              setState(() {});
            },
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TanTitulo('Configurações', size: 15),
            const SizedBox(height: 20),
            const TanSubtitulo('Aparência'),
            const SizedBox(height: 10),
            const TanRotulo('Tema'),
            Align(
              alignment: Alignment.centerLeft,
              child: TanSegmentado<String>(
                opcoes: const [
                  ('light', 'Claro'),
                  ('dark', 'Escuro'),
                  ('system', 'Do Windows'),
                ],
                valor: tema,
                onChanged: (v) async {
                  await MyTheme.changeDarkMode(MyTheme.themeModeFromString(v));
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 26),
            const TanSubtitulo('Sessão remota'),
            const SizedBox(height: 10),
            const TanRotulo('Qualidade padrão da imagem'),
            Align(
              alignment: Alignment.centerLeft,
              child: TanSegmentado<String>(
                opcoes: const [
                  (kRemoteImageQualityBest, 'Melhor imagem'),
                  (kRemoteImageQualityBalanced, 'Balanceada'),
                  (kRemoteImageQualityLow, 'Mais rápida'),
                ],
                valor: qualidade,
                onChanged: (v) async {
                  await bind.mainSetUserDefaultOption(
                      key: kOptionImageQuality, value: v);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),
            TanLinha(
              rotulo: 'Ajustar a tela do cliente à janela',
              direita: TanChave(
                valor: ajustar,
                onChanged: (v) async {
                  await bind.mainSetUserDefaultOption(
                      key: kOptionViewStyle,
                      value: v ? kRemoteViewStyleAdaptive : kRemoteViewStyleOriginal);
                  setState(() {});
                },
              ),
            ),
            TanLinha(
              rotulo: 'Abrir as conexões em abas de uma janela só',
              ultima: true,
              direita: TanChave(
                valor: abas,
                onChanged: (v) async {
                  await mainSetLocalBoolOption(kOptionOpenNewConnInTabs, v);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 26),
            const TanSubtitulo('Quando alguém acessar este computador'),
            const SizedBox(height: 6),
            TanLinha(
              rotulo: 'Senha fixa',
              direita: TanLink('Definir', onTap: () => setPasswordDialog()),
            ),
            permissao('Permitir controle do teclado e do mouse',
                kOptionEnableKeyboard),
            permissao('Permitir transferência de arquivos',
                kOptionEnableFileTransfer),
            permissao('Permitir área de transferência (copiar e colar)',
                kOptionEnableClipboard),
            permissao('Permitir áudio', kOptionEnableAudio, ultima: true),
          ],
        ),
      ),
    );
  }
}
