// TAN! Suporte: lista de dispositivos (recentes ou favoritos) em linhas, no lugar dos cartoes
// coloridos do RustDesk. O icone do computador mostra se esta online.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/formatter/id_formatter.dart';
import 'package:flutter_hbb/common/widgets/dialog.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/models/peer_model.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:provider/provider.dart';

enum TanTipoLista { recentes, favoritos }

class TanListaDispositivos extends StatefulWidget {
  const TanListaDispositivos({Key? key, required this.tipo, this.busca = ''})
      : super(key: key);

  final TanTipoLista tipo;
  final String busca;

  @override
  State<TanListaDispositivos> createState() => _TanListaDispositivosState();
}

class _TanListaDispositivosState extends State<TanListaDispositivos> {
  Timer? _timerOnline;
  List<String> _favoritos = [];

  Peers get _modelo => widget.tipo == TanTipoLista.recentes
      ? gFFI.recentPeersModel
      : gFFI.favoritePeersModel;

  @override
  void initState() {
    super.initState();
    _carregar();
    // o servidor so responde quem esta online quando perguntado
    _timerOnline = Timer.periodic(const Duration(seconds: 20), (_) {
      _perguntarOnline();
    });
  }

  @override
  void dispose() {
    _timerOnline?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    if (widget.tipo == TanTipoLista.recentes) {
      await bind.mainLoadRecentPeers();
    } else {
      await bind.mainLoadFavPeers();
    }
    _favoritos = (await bind.mainGetFav()).toList();
    if (mounted) setState(() {});
    Future.delayed(const Duration(milliseconds: 600), _perguntarOnline);
  }

  void _perguntarOnline() {
    final ids = _modelo.peers.map((p) => p.id).toList();
    if (ids.isNotEmpty) bind.queryOnlines(ids: ids);
  }

  Future<void> _alternarFavorito(String id) async {
    final favs = (await bind.mainGetFav()).toList();
    if (!favs.remove(id)) favs.add(id);
    await bind.mainStoreFav(favs: favs);
    _favoritos = favs;
    if (widget.tipo == TanTipoLista.favoritos) {
      await bind.mainLoadFavPeers();
    }
    if (mounted) setState(() {});
  }

  Future<void> _remover(Peer p) async {
    if (widget.tipo == TanTipoLista.recentes) {
      await bind.mainRemovePeer(id: p.id);
      await bind.mainLoadRecentPeers();
    } else {
      await _alternarFavorito(p.id);
    }
  }

  void _renomear(Peer p) {
    renameDialog(
        oldName: p.alias,
        onSubmit: (nome) async {
          await bind.mainSetPeerAlias(id: p.id, alias: nome.trim());
          await _carregar();
        });
  }

  bool _combina(Peer p) {
    final b = tanSemEspacos(widget.busca).toLowerCase();
    if (b.isEmpty) return true;
    return p.id.contains(b) ||
        p.alias.toLowerCase().contains(b) ||
        p.hostname.toLowerCase().contains(b) ||
        p.username.toLowerCase().contains(b);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Peers>.value(
      value: _modelo,
      child: Consumer<Peers>(builder: (context, modelo, _) {
        final peers = modelo.peers.where(_combina).toList();
        if (peers.isEmpty) return _vazio(context);
        return ListView.builder(
          itemCount: peers.length,
          itemBuilder: (context, i) => _Linha(
            peer: peers[i],
            favorito: _favoritos.contains(peers[i].id),
            onConectar: () => connect(context, peers[i].id),
            onArquivos: () =>
                connect(context, peers[i].id, isFileTransfer: true),
            onFavorito: () => _alternarFavorito(peers[i].id),
            onRenomear: () => _renomear(peers[i]),
            onRemover: () => _remover(peers[i]),
            textoRemover: widget.tipo == TanTipoLista.recentes
                ? 'Remover dos recentes'
                : 'Tirar dos favoritos',
          ),
        );
      }),
    );
  }

  Widget _vazio(BuildContext context) {
    final c = TanCores.of(context);
    final texto = widget.busca.isNotEmpty
        ? 'Nenhum dispositivo encontrado.'
        : widget.tipo == TanTipoLista.recentes
            ? 'Os computadores que você acessar aparecem aqui.'
            : 'Marque a estrela de um computador para ele aparecer aqui.';
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Text(texto,
          textAlign: TextAlign.center,
          style: tanTexto(context, size: 12.5, cor: c.dica)),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.peer,
    required this.favorito,
    required this.onConectar,
    required this.onArquivos,
    required this.onFavorito,
    required this.onRenomear,
    required this.onRemover,
    required this.textoRemover,
  });

  final Peer peer;
  final bool favorito;
  final VoidCallback onConectar;
  final VoidCallback onArquivos;
  final VoidCallback onFavorito;
  final VoidCallback onRenomear;
  final VoidCallback onRemover;
  final String textoRemover;

  String get _nome {
    if (peer.alias.isNotEmpty) return peer.alias;
    if (peer.hostname.isNotEmpty) return peer.hostname;
    return formatID(peer.id);
  }

  String get _detalhe {
    final partes = <String>[
      if (peer.username.isNotEmpty) peer.username,
      if (peer.alias.isNotEmpty && peer.hostname.isNotEmpty) peer.hostname,
      if (peer.platform.isNotEmpty) peer.platform,
    ];
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    final apagado = !peer.online;
    return GestureDetector(
      onDoubleTap: onConectar,
      child: TanToque(
        onTap: () {},
        builder: (context, sobre) => Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: sobre ? c.selecionado : null,
            border: Border(bottom: BorderSide(color: c.linha)),
          ),
          child: Row(
            children: [
              Tooltip(
                message: peer.online ? 'Online' : 'Offline',
                child: Icon(
                    peer.online
                        ? Icons.desktop_windows_outlined
                        : Icons.desktop_access_disabled_outlined,
                    size: 20,
                    color: peer.online ? c.ok : c.dica),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tanTexto(context,
                            size: 13,
                            peso: FontWeight.w600,
                            cor: apagado ? c.textoVar : c.texto)),
                    if (_detalhe.isNotEmpty)
                      Text(_detalhe,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tanTexto(context, size: 11.5, cor: c.dica)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 104,
                child: Text(formatID(peer.id),
                    textAlign: TextAlign.right,
                    style: tanTexto(context, size: 12, cor: c.textoVar)),
              ),
              const SizedBox(width: 8),
              TanIcone(
                  favorito ? Icons.star_rounded : Icons.star_outline_rounded,
                  dica: favorito ? 'Tirar dos favoritos' : 'Favoritar',
                  cor: favorito ? kTanLaranja : null,
                  onTap: onFavorito),
              Builder(
                builder: (context) => TanIcone(Icons.more_horiz_rounded,
                    dica: 'Mais opções', onTap: () => _menu(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _menu(BuildContext context) {
    final c = TanCores.of(context);
    final caixa = context.findRenderObject() as RenderBox;
    final pos = caixa.localToGlobal(Offset(0, caixa.size.height));
    item(String texto, VoidCallback acao, {bool perigo = false}) =>
        PopupMenuItem<VoidCallback>(
          value: acao,
          height: 36,
          child: Text(texto,
              style: tanTexto(context,
                  size: 12.5, cor: perigo ? c.bad : c.texto)),
        );
    showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx - 160, pos.dy, pos.dx, 0),
      items: [
        item('Conectar', onConectar),
        item('Transferir arquivos', onArquivos),
        item('Renomear', onRenomear),
        item(textoRemover, onRemover, perigo: true),
      ],
    ).then((acao) => acao?.call());
  }
}

/// Tela "Favoritos" do menu lateral.
class TanTelaFavoritos extends StatefulWidget {
  const TanTelaFavoritos({Key? key}) : super(key: key);

  @override
  State<TanTelaFavoritos> createState() => _TanTelaFavoritosState();
}

class _TanTelaFavoritosState extends State<TanTelaFavoritos> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: TanTitulo('Favoritos', size: 15)),
              TanBusca(onChanged: (v) => setState(() => _busca = v)),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
              child: TanListaDispositivos(
                  tipo: TanTipoLista.favoritos, busca: _busca)),
        ],
      ),
    );
  }
}

/// Campo de busca compacto.
class TanBusca extends StatelessWidget {
  const TanBusca({Key? key, required this.onChanged}) : super(key: key);

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return SizedBox(
      width: 220,
      height: 32,
      child: TextField(
        onChanged: onChanged,
        style: tanTexto(context, size: 12.5),
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou ID',
          hintStyle: tanTexto(context, size: 12, cor: c.dica),
          prefixIcon: Icon(Icons.search_rounded, size: 17, color: c.dica),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 32, minHeight: 32),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
