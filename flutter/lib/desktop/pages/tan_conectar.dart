// TAN! Suporte: tela "Acesso remoto" do tecnico: ID do cliente, Conectar/Arquivos e os recentes.
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/formatter/id_formatter.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/desktop/pages/tan_lista.dart';
import 'package:flutter_hbb/models/platform_model.dart';

class TanConectar extends StatefulWidget {
  const TanConectar({Key? key}) : super(key: key);

  @override
  State<TanConectar> createState() => _TanConectarState();
}

class _TanConectarState extends State<TanConectar> {
  final _id = IDTextEditingController();
  final _foco = FocusNode();
  String _busca = '';

  @override
  void initState() {
    super.initState();
    bind.mainGetLastRemoteId().then((ultimo) {
      if (mounted && _id.text.isEmpty) setState(() => _id.id = ultimo);
    });
  }

  @override
  void dispose() {
    _id.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _conectar({bool arquivos = false}) {
    final id = _id.id.trim();
    if (id.isEmpty) {
      _foco.requestFocus();
      return;
    }
    connect(context, id, isFileTransfer: arquivos);
  }

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TanTitulo('Conectar a um cliente', size: 15),
          const SizedBox(height: 14),
          const TanRotulo('ID do cliente'),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _id,
                    focusNode: _foco,
                    autofocus: true,
                    inputFormatters: [IDTextInputFormatter()],
                    onSubmitted: (_) => _conectar(),
                    style: tanTexto(context,
                        size: 17, peso: FontWeight.w600, cor: c.titulo),
                    decoration: InputDecoration(
                      hintText: 'Digite o ID que o cliente passou',
                      hintStyle: tanTexto(context, size: 13.5, cor: c.dica),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TanBotao(
                  texto: 'Conectar',
                  icone: Icons.cast_connected_rounded,
                  height: 44,
                  onTap: () => _conectar()),
              const SizedBox(width: 6),
              TanToque(
                dica: 'Abrir só a transferência de arquivos',
                onTap: () => _conectar(arquivos: true),
                builder: (context, sobre) => Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                      color: sobre ? c.blocoSobre : c.bloco,
                      borderRadius: kTanRaioPeca),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 17, color: c.titulo),
                      const SizedBox(width: 7),
                      Text('Arquivos',
                          style: tanTexto(context,
                              size: 13, peso: FontWeight.w600, cor: c.titulo)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(child: TanSubtitulo('Recentes')),
              TanBusca(onChanged: (v) => setState(() => _busca = v)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
              child: TanListaDispositivos(
                  tipo: TanTipoLista.recentes, busca: _busca)),
        ],
      ),
    );
  }
}
