// TAN! Suporte: tela inicial do executavel do cliente (modo "so receber conexao").
// Substitui o painel esquerdo padrao quando bind.isIncomingOnly() (ver desktop_home_page.dart).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:provider/provider.dart';

class TanClienteHome extends StatefulWidget {
  const TanClienteHome(
      {Key? key, required this.contentKey, required this.onLayoutChanged})
      : super(key: key);

  /// Chave do conteudo medido para ajustar o tamanho da janela.
  final GlobalKey contentKey;
  final VoidCallback onLayoutChanged;

  @override
  State<TanClienteHome> createState() => _TanClienteHomeState();
}

class _TanClienteHomeState extends State<TanClienteHome>
    with TanStatusPolling {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onLayoutChanged());
  }

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Container(
        width: 360,
        color: c.fundo,
        child: SingleChildScrollView(
          child: Padding(
            key: widget.contentKey,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TanCabecalho(),
                const SizedBox(height: 8),
                TanPainel(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Consumer<ServerModel>(
                    builder: (context, model, _) => _corpo(context, model),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context, ServerModel model) {
    final c = TanCores.of(context);
    final mostraSenha = model.approveMode != 'click' &&
        model.verificationMethod != kUsePermanentPassword;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TanTitulo('Seu acesso'),
        const SizedBox(height: 8),
        Text('Passe o ID e a senha para o técnico da TAN!.',
            style: tanTexto(context, size: 12.5, cor: c.textoVar)),
        const SizedBox(height: 14),
        const TanRotulo('Seu ID'),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: model.serverId,
          builder: (context, id, _) => TanBloco(
            height: 46,
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(id.text.isEmpty ? '...' : id.text,
                      maxLines: 1,
                      style: tanTexto(context,
                          size: 22, peso: FontWeight.w700, cor: c.titulo)),
                ),
                TanLink('Copiar',
                    onTap: () =>
                        tanCopiar(tanSemEspacos(id.text), 'ID copiado')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const TanRotulo('Senha'),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: model.serverPasswd,
          builder: (context, senha, _) => TanBloco(
            height: 42,
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                      mostraSenha ? senha.text : 'Aceite no aviso que vai aparecer',
                      maxLines: 1,
                      style: tanTexto(context,
                          size: mostraSenha ? 18 : 12.5,
                          peso:
                              mostraSenha ? FontWeight.w600 : FontWeight.w400)),
                ),
                if (mostraSenha) ...[
                  TanLink('Nova senha',
                      onTap: () => bind.mainUpdateTemporaryPassword()),
                  const SizedBox(width: 14),
                  TanLink('Copiar',
                      onTap: () => tanCopiar(senha.text, 'Senha copiada')),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        TanBotao(
          texto: 'Copiar ID e senha',
          icone: Icons.copy_rounded,
          height: 38,
          onTap: () {
            final id = tanSemEspacos(model.serverId.text);
            tanCopiar(
                mostraSenha
                    ? 'ID: $id\nSenha: ${model.serverPasswd.text}'
                    : 'ID: $id',
                'Copiado. Cole na conversa com o técnico.');
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.linha))),
          child: Row(
            children: [
              TanEstado(tanStatus),
              const Spacer(),
              TanLink('Fechar', onTap: () {
                SystemNavigator.pop();
                // https://github.com/flutter/flutter/issues/66631
                if (isWindows) {
                  exit(0);
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}
