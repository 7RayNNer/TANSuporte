// TAN! Suporte: casca da tela inicial do executavel do tecnico. Cabecalho com logo e estado,
// menu a esquerda com "Este computador" no pe, e a area de conexao (ConnectionPage) a direita.
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/desktop/pages/desktop_tab_page.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:provider/provider.dart';

class TanTecnicoHome extends StatefulWidget {
  const TanTecnicoHome({Key? key, required this.conectar}) : super(key: key);

  /// Area de conexao (a ConnectionPage do RustDesk, restilizada).
  final Widget conectar;

  @override
  State<TanTecnicoHome> createState() => _TanTecnicoHomeState();
}

class _TanTecnicoHomeState extends State<TanTecnicoHome>
    with TanStatusPolling {
  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return Container(
      color: c.fundo,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TanCabecalho(complemento: 'Técnico', direita: TanEstado(tanStatus)),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 214, child: _menu(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: TanPainel(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
                    child: widget.conectar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return TanPainel(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ItemMenu(
              icone: Icons.desktop_windows_outlined,
              texto: 'Acesso remoto',
              ativo: true),
          _ItemMenu(
              icone: Icons.settings_outlined,
              texto: 'Configurações',
              onTap: () => DesktopTabPage.onAddSetting()),
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
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      padding: const EdgeInsets.only(top: 12),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: c.linha))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TanTitulo('Este computador', size: 13),
          const SizedBox(height: 10),
          const TanRotulo('Seu ID'),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: model.serverId,
            builder: (context, id, _) => Row(
              children: [
                Expanded(
                  child: SelectableText(id.text.isEmpty ? '...' : id.text,
                      maxLines: 1,
                      style: tanTexto(context,
                          size: 16, peso: FontWeight.w700, cor: c.titulo)),
                ),
                TanLink('Copiar',
                    onTap: () =>
                        tanCopiar(tanSemEspacos(id.text), 'ID copiado')),
              ],
            ),
          ),
          if (mostraSenha) ...[
            const SizedBox(height: 10),
            const TanRotulo('Senha'),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: model.serverPasswd,
              builder: (context, senha, _) => Row(
                children: [
                  Expanded(
                    child: SelectableText(senha.text,
                        maxLines: 1,
                        style: tanTexto(context,
                            size: 14, peso: FontWeight.w600)),
                  ),
                  TanLink('Nova',
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
      this.ativo = false,
      this.onTap});

  final IconData icone;
  final String texto;
  final bool ativo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return TanToque(
      onTap: onTap,
      builder: (context, sobre) => Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ativo || sobre ? c.selecionado : null,
          border: Border(
              left: BorderSide(
                  color: ativo ? kTanLaranja : Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icone, size: 18, color: ativo ? kTanLaranja : c.titulo),
            const SizedBox(width: 10),
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
