// TAN! Suporte: tela inicial do executavel do cliente (modo "so receber conexao").
// Substitui o painel esquerdo padrao quando bind.isIncomingOnly() (ver desktop_home_page.dart).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:provider/provider.dart';

const _azul = Color(0xFF1E3A8A);
const _azulClaro = Color(0xFFB5D4F4);
// ID no modo escuro: o azul da marca some no fundo escuro.
const _azulIdEscuro = Color(0xFF85B7EB);
const _laranja = Color(0xFFF26522);
const _verde = Color(0xFF639922);
const _amarelo = Color(0xFFEF9F27);
const _vermelho = Color(0xFFE24B4A);

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

enum _Status { conectando, pronto, offline }

class _TanClienteHomeState extends State<TanClienteHome> {
  Timer? _timer;
  _Status _status = _Status.conectando;

  @override
  void initState() {
    super.initState();
    _timer = periodic_immediate(const Duration(seconds: 1), _atualizarStatus);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onLayoutChanged());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _atualizarStatus() async {
    final status =
        jsonDecode(await bind.mainGetConnectStatus()) as Map<String, dynamic>;
    final n = status['status_num'] as int;
    final novo = n == 1
        ? _Status.pronto
        : n == 0
            ? _Status.conectando
            : _Status.offline;
    if (mounted && novo != _status) {
      setState(() => _status = novo);
    }
  }

  void _copiar(String texto, String aviso) {
    Clipboard.setData(ClipboardData(text: texto));
    showToast(aviso);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Container(
        width: 360,
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          child: Column(
            key: widget.contentKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabecalho(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Consumer<ServerModel>(
                  builder: (context, model, _) => _corpo(context, model),
                ),
              ),
              _rodape(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Container(
      color: _azul,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: loadIcon(40),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TAN! Suporte',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Acesso remoto seguro',
                  style: TextStyle(color: _azulClaro, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _corpo(BuildContext context, ServerModel model) {
    final textoSecundario =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);
    final mostraSenhaTemporaria = model.approveMode != 'click' &&
        model.verificationMethod != kUsePermanentPassword;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informe o ID e a senha abaixo ao técnico da TAN! para receber atendimento.',
          style: TextStyle(fontSize: 13, height: 1.5, color: textoSecundario),
        ),
        const SizedBox(height: 14),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: model.serverId,
          builder: (context, id, _) => _cartao(
            context,
            rotulo: 'Seu ID',
            valor: id.text.isEmpty ? '...' : id.text,
            estiloValor: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Theme.of(context).brightness == Brightness.dark
                    ? _azulIdEscuro
                    : _azul),
            acoes: [
              _botaoIcone(Icons.copy_rounded, 'Copiar ID',
                  () => _copiar(_semEspacos(id.text), 'ID copiado')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: model.serverPasswd,
          builder: (context, senha, _) => _cartao(
            context,
            rotulo: 'Senha',
            valor: mostraSenhaTemporaria ? senha.text : 'Aceite no aviso',
            estiloValor: TextStyle(
                fontSize: mostraSenhaTemporaria ? 20 : 15,
                fontWeight: FontWeight.w600,
                letterSpacing: mostraSenhaTemporaria ? 1 : 0,
                fontFamily: mostraSenhaTemporaria ? 'monospace' : null),
            acoes: [
              if (mostraSenhaTemporaria)
                _botaoIcone(Icons.refresh_rounded, 'Gerar nova senha',
                    () => bind.mainUpdateTemporaryPassword()),
              if (mostraSenhaTemporaria)
                _botaoIcone(Icons.copy_rounded, 'Copiar senha',
                    () => _copiar(senha.text, 'Senha copiada')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _laranja,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.content_paste_rounded, size: 18),
            label: const Text('Copiar ID e senha',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            onPressed: () {
              final id = _semEspacos(model.serverId.text);
              final texto = mostraSenhaTemporaria
                  ? 'ID: $id\nSenha: ${model.serverPasswd.text}'
                  : 'ID: $id';
              _copiar(texto, 'Copiado. Cole na conversa com o técnico.');
            },
          ),
        ),
      ],
    );
  }

  Widget _cartao(BuildContext context,
      {required String rotulo,
      required String valor,
      required TextStyle estiloValor,
      required List<Widget> acoes}) {
    final borda = Theme.of(context).dividerColor;
    final textoSecundario =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo,
                    style: TextStyle(fontSize: 12, color: textoSecundario)),
                const SizedBox(height: 2),
                SelectableText(valor, style: estiloValor, maxLines: 1),
              ],
            ),
          ),
          ...acoes,
        ],
      ),
    );
  }

  Widget _botaoIcone(IconData icone, String dica, VoidCallback acao) {
    return IconButton(
      tooltip: dica,
      splashRadius: 18,
      icon: Icon(icone, size: 20),
      color: Colors.grey,
      onPressed: acao,
    );
  }

  Widget _rodape(BuildContext context) {
    final (cor, texto) = switch (_status) {
      _Status.pronto => (_verde, 'Pronto para conectar'),
      _Status.conectando => (_amarelo, 'Conectando ao servidor...'),
      _Status.offline => (_vermelho, 'Sem conexão com o servidor'),
    };
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
              // https://github.com/flutter/flutter/issues/66631
              if (isWindows) {
                exit(0);
              }
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

String _semEspacos(String s) => s.replaceAll(' ', '');
