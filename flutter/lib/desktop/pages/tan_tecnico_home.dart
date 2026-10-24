// TAN! Suporte: janela principal do tecnico. Barra de titulo propria, menu lateral e as telas
// (Acesso remoto, Favoritos, Configuracoes, Sobre) trocadas na mesma janela, sem as abas do RustDesk.
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/desktop/pages/tan_configuracoes.dart';
import 'package:flutter_hbb/desktop/pages/tan_conectar.dart';
import 'package:flutter_hbb/desktop/pages/tan_lista.dart';
import 'package:flutter_hbb/desktop/pages/tan_sobre.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum TanTela { acesso, favoritos, configuracoes, sobre }

class TanTecnicoHome extends StatefulWidget {
  const TanTecnicoHome({Key? key}) : super(key: key);

  @override
  State<TanTecnicoHome> createState() => _TanTecnicoHomeState();
}

class _TanTecnicoHomeState extends State<TanTecnicoHome>
    with TanStatusPolling {
  TanTela _tela = TanTela.acesso;

  String get _versao => bind.mainGetBuildinOption(key: 'tan-versao');

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return Container(
      color: c.fundo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TanBarraTitulo(
            complemento: 'Técnico · v$_versao',
            direita: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // versao nova nas releases da TAN (src/tan_update.rs)
                Obx(() => stateGlobal.updateUrl.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: TanLink('Nova versão disponível',
                            onTap: () => launchUrlString(
                                stateGlobal.updateUrl.value)),
                      )),
                TanEstado(tanStatus, curto: true),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 200, child: _menu(context)),
                  const SizedBox(width: 10),
                  Expanded(child: TanPainel(child: _conteudo())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    return switch (_tela) {
      TanTela.acesso => const TanConectar(),
      TanTela.favoritos => const TanTelaFavoritos(),
      TanTela.configuracoes => const TanConfiguracoes(),
      TanTela.sobre => const TanSobre(),
    };
  }

  Widget _menu(BuildContext context) {
    item(TanTela tela, IconData icone, String texto) => _ItemMenu(
        icone: icone,
        texto: texto,
        ativo: _tela == tela,
        onTap: () => setState(() => _tela = tela));
    return TanPainel(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          item(TanTela.acesso, Icons.desktop_windows_outlined, 'Acesso remoto'),
          item(TanTela.favoritos, Icons.star_outline_rounded, 'Favoritos'),
          item(TanTela.configuracoes, Icons.tune_rounded, 'Configurações'),
          item(TanTela.sobre, Icons.info_outline_rounded, 'Sobre'),
          const Spacer(),
          ChangeNotifierProvider.value(
            value: gFFI.serverModel,
            child: Consumer<ServerModel>(
              builder: (context, model, _) => _esteComputador(context, model),
            ),
          ),
        ],
      ),
    );
  }

  Widget _esteComputador(BuildContext context, ServerModel model) {
    final c = TanCores.of(context);
    final mostraSenha = model.approveMode != 'click' &&
        model.verificationMethod != kUsePermanentPassword;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 2),
      padding: const EdgeInsets.only(top: 12),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: c.linha))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TanRotulo('Este computador'),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: model.serverId,
            builder: (context, id, _) => Row(
              children: [
                Expanded(
                  child: SelectableText(id.text.isEmpty ? '...' : id.text,
                      maxLines: 1,
                      style: tanTexto(context,
                          size: 15, peso: FontWeight.w700, cor: c.titulo)),
                ),
                TanLink('Copiar',
                    onTap: () =>
                        tanCopiar(tanSemEspacos(id.text), 'ID copiado')),
              ],
            ),
          ),
          if (mostraSenha) ...[
            const SizedBox(height: 4),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: model.serverPasswd,
              builder: (context, senha, _) => Row(
                children: [
                  Expanded(
                    child: SelectableText(senha.text,
                        maxLines: 1,
                        style: tanTexto(context,
                            size: 13, cor: c.textoVar)),
                  ),
                  TanLink('Nova senha',
                      onTap: () => bind.mainUpdateTemporaryPassword()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu(
      {required this.icone,
      required this.texto,
      required this.ativo,
      required this.onTap});

  final IconData icone;
  final String texto;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return TanToque(
      onTap: onTap,
      builder: (context, sobre) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ativo || sobre ? c.selecionado : null,
          border: Border(
              left: BorderSide(
                  color: ativo ? kTanLaranja : Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icone, size: 18, color: ativo ? kTanLaranja : c.titulo),
            const SizedBox(width: 11),
            Text(texto,
                style: tanTexto(context,
                    size: 13.5,
                    peso: ativo ? FontWeight.w600 : FontWeight.w400,
                    cor: ativo ? c.titulo : c.texto)),
          ],
        ),
      ),
    );
  }
}
