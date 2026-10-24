// TAN! Suporte: pecas visuais das telas do cliente e do tecnico, na linguagem do TAN! Web
// (TANWeb/lib/tema/tema.dart e lib/widgets/blocos.dart): fundo cinza-azulado, paineis brancos de
// canto quase reto, titulo com barrinha laranja, campo como bloco chapado sem contorno, botao azul
// cheio, estado como bolinha + texto, fonte Inter. A barrinha laranja fica so no titulo principal
// de cada tela (TanTitulo); secoes usam TanSubtitulo.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

const kTanFonte = 'Inter';
const kTanAzul = Color(0xFF1F3B73);
const kTanLaranja = Color(0xFFF26522);
const kTanRaioBloco = BorderRadius.all(Radius.circular(4));
const kTanRaioPeca = BorderRadius.all(Radius.circular(3));

/// Cores que mudam entre claro e escuro (claro = TAN! Web; escuro = grafite do TAN! Web).
class TanCores {
  final Color fundo, painel, bloco, blocoSobre, linha, texto, textoVar, dica;
  final Color titulo, selecionado, ok, pend, bad, botao, botaoTexto;

  const TanCores._({
    required this.fundo,
    required this.painel,
    required this.bloco,
    required this.blocoSobre,
    required this.linha,
    required this.texto,
    required this.textoVar,
    required this.dica,
    required this.titulo,
    required this.selecionado,
    required this.ok,
    required this.pend,
    required this.bad,
    required this.botao,
    required this.botaoTexto,
  });

  static const claro = TanCores._(
    fundo: Color(0xFFE1E6EE),
    painel: Colors.white,
    bloco: Color(0xFFD8E1ED),
    blocoSobre: Color(0xFFCBD8EB),
    linha: Color(0xFFC7D6EB),
    texto: Color(0xFF253047),
    textoVar: Color(0xFF556079),
    dica: Color(0xFF7A8499),
    titulo: kTanAzul,
    selecionado: Color(0xFFE3EBF8),
    ok: Color(0xFF1F7A3D),
    pend: Color(0xFF9A6A0A),
    bad: Color(0xFFB4311F),
    botao: kTanAzul,
    botaoTexto: Colors.white,
  );

  static const escuro = TanCores._(
    fundo: Color(0xFF111317),
    painel: Color(0xFF1C1F25),
    bloco: Color(0xFF272A31),
    blocoSobre: Color(0xFF31353D),
    linha: Color(0xFF363A43),
    texto: Color(0xFFE3E5EA),
    textoVar: Color(0xFFA0A5AF),
    dica: Color(0xFF737884),
    titulo: Color(0xFFC9CED8),
    selecionado: Color(0xFF2A2E36),
    ok: Color(0xFF5DD08C),
    pend: Color(0xFFE2AC4D),
    bad: Color(0xFFF08A78),
    botao: Color(0xFFC9CED8),
    botaoTexto: Color(0xFF1B1F27),
  );

  static TanCores of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? escuro : claro;
}

TextStyle tanTexto(BuildContext context,
        {double size = 13, FontWeight peso = FontWeight.w400, Color? cor}) =>
    TextStyle(
        fontFamily: kTanFonte,
        fontSize: size,
        fontWeight: peso,
        letterSpacing: 0,
        color: cor ?? TanCores.of(context).texto);

/// Painel branco de canto leve.
class TanPainel extends StatelessWidget {
  const TanPainel({Key? key, required this.child, this.padding})
      : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: TanCores.of(context).painel, borderRadius: kTanRaioBloco),
        child: child,
      );
}

/// Titulo de secao com a barrinha laranja antes.
class TanTitulo extends StatelessWidget {
  const TanTitulo(this.texto, {Key? key, this.size = 14}) : super(key: key);

  final String texto;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 3, height: size + 2, color: kTanLaranja),
          const SizedBox(width: 8),
          Text(texto,
              style: tanTexto(context,
                  size: size,
                  peso: FontWeight.w600,
                  cor: TanCores.of(context).titulo)),
        ],
      );
}

/// Rotulo pequeno acima do campo.
class TanRotulo extends StatelessWidget {
  const TanRotulo(this.texto, {Key? key}) : super(key: key);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(texto,
            style: tanTexto(context,
                size: 11.5, cor: TanCores.of(context).textoVar)),
      );
}

/// Bloco chapado (campo somente leitura).
class TanBloco extends StatelessWidget {
  const TanBloco(
      {Key? key, required this.child, this.height = 40, this.padding})
      : super(key: key);

  final Widget child;
  final double height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: TanCores.of(context).bloco, borderRadius: kTanRaioPeca),
        alignment: Alignment.centerLeft,
        child: child,
      );
}

/// Area clicavel sem a tinta do Material: o estado e desenhado pelo [builder].
class TanToque extends StatefulWidget {
  const TanToque({Key? key, required this.builder, this.onTap, this.dica})
      : super(key: key);

  final VoidCallback? onTap;
  final String? dica;
  final Widget Function(BuildContext context, bool sobre) builder;

  @override
  State<TanToque> createState() => _TanToqueState();
}

class _TanToqueState extends State<TanToque> {
  bool _sobre = false;

  @override
  Widget build(BuildContext context) {
    final w = InkWell(
      onTap: widget.onTap,
      onHover: (v) => setState(() => _sobre = v),
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      child: widget.builder(context, widget.onTap != null && _sobre),
    );
    return widget.dica == null ? w : Tooltip(message: widget.dica!, child: w);
  }
}

/// Botao principal: bloco azul cheio.
class TanBotao extends StatelessWidget {
  const TanBotao(
      {Key? key,
      required this.texto,
      required this.onTap,
      this.icone,
      this.height = 36})
      : super(key: key);

  final String texto;
  final IconData? icone;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return TanToque(
      onTap: onTap,
      builder: (context, sobre) => Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: sobre ? Color.lerp(c.botao, Colors.white, 0.12) : c.botao,
          borderRadius: kTanRaioPeca,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) Icon(icone, size: 16, color: c.botaoTexto),
            if (icone != null) const SizedBox(width: 7),
            Text(texto,
                style: tanTexto(context,
                    size: 13, peso: FontWeight.w600, cor: c.botaoTexto)),
          ],
        ),
      ),
    );
  }
}

/// Acao em texto (como "Trocar logotipo" no TAN! Web).
class TanLink extends StatelessWidget {
  const TanLink(this.texto, {Key? key, required this.onTap}) : super(key: key);

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TanToque(
        onTap: onTap,
        builder: (context, sobre) => Text(texto,
            style: tanTexto(context,
                    size: 12,
                    peso: FontWeight.w600,
                    cor: TanCores.of(context).titulo)
                .copyWith(
                    decoration: sobre ? TextDecoration.underline : null,
                    decorationColor: TanCores.of(context).titulo)),
      );
}

enum TanStatus { conectando, pronto, offline }

/// Estado como bolinha colorida + texto.
class TanEstado extends StatelessWidget {
  const TanEstado(this.status, {Key? key, this.curto = false})
      : super(key: key);

  final TanStatus status;

  /// "Pronto" em vez de "Pronto para conectar" (barra de titulo do tecnico).
  final bool curto;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    final (cor, texto) = switch (status) {
      TanStatus.pronto => (c.ok, curto ? 'Pronto' : 'Pronto para conectar'),
      TanStatus.conectando =>
        (c.pend, curto ? 'Conectando...' : 'Conectando ao servidor...'),
      TanStatus.offline =>
        (c.bad, curto ? 'Sem servidor' : 'Sem conexão com o servidor'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Flexible(
          child: Text(texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tanTexto(context, size: 12, cor: c.textoVar)),
        ),
      ],
    );
  }
}

/// Faixa do topo: logo, nome do produto, complemento e o que vai a direita.
class TanCabecalho extends StatelessWidget {
  const TanCabecalho({Key? key, this.complemento, this.direita})
      : super(key: key);

  final String? complemento;
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return TanPainel(
      padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
      child: Row(
        children: [
          ClipRRect(
              borderRadius: kTanRaioPeca,
              child: SizedBox(width: 28, height: 28, child: loadIcon(28))),
          const SizedBox(width: 10),
          Text('TAN! Suporte',
              style: tanTexto(context,
                  size: 15, peso: FontWeight.w700, cor: c.titulo)),
          if (complemento != null) ...[
            const SizedBox(width: 8),
            Text('· $complemento',
                style: tanTexto(context, size: 12, cor: c.textoVar)),
          ],
          const Spacer(),
          if (direita != null) direita!,
        ],
      ),
    );
  }
}

/// Consulta o status do servidor a cada segundo.
mixin TanStatusPolling<T extends StatefulWidget> on State<T> {
  Timer? _tanTimer;
  TanStatus tanStatus = TanStatus.conectando;

  @override
  void initState() {
    super.initState();
    _tanTimer = periodic_immediate(const Duration(seconds: 1), () async {
      final status = jsonDecode(await bind.mainGetConnectStatus())
          as Map<String, dynamic>;
      final n = status['status_num'] as int;
      final novo = n == 1
          ? TanStatus.pronto
          : n == 0
              ? TanStatus.conectando
              : TanStatus.offline;
      if (mounted && novo != tanStatus) {
        setState(() => tanStatus = novo);
      }
    });
  }

  @override
  void dispose() {
    _tanTimer?.cancel();
    super.dispose();
  }
}

void tanCopiar(String texto, String aviso) {
  Clipboard.setData(ClipboardData(text: texto));
  showToast(aviso);
}

String tanSemEspacos(String s) => s.replaceAll(' ', '');

/// Titulo de secao dentro de uma tela: azul, sem barrinha.
class TanSubtitulo extends StatelessWidget {
  const TanSubtitulo(this.texto, {Key? key}) : super(key: key);

  final String texto;

  @override
  Widget build(BuildContext context) => Text(texto,
      style: tanTexto(context,
          size: 13, peso: FontWeight.w600, cor: TanCores.of(context).titulo));
}

/// Linha de configuracao/informacao: rotulo a esquerda, conteudo a direita, fio embaixo.
class TanLinha extends StatelessWidget {
  const TanLinha(
      {Key? key,
      required this.rotulo,
      required this.direita,
      this.ultima = false})
      : super(key: key);

  final String rotulo;
  final Widget direita;
  final bool ultima;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
          border: ultima ? null : Border(bottom: BorderSide(color: c.linha))),
      child: Row(
        children: [
          Expanded(child: Text(rotulo, style: tanTexto(context, size: 13))),
          const SizedBox(width: 12),
          direita,
        ],
      ),
    );
  }
}

/// Chave liga/desliga de canto reto.
class TanChave extends StatelessWidget {
  const TanChave({Key? key, required this.valor, required this.onChanged})
      : super(key: key);

  final bool valor;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return TanToque(
      onTap: onChanged == null ? null : () => onChanged!(!valor),
      builder: (context, sobre) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 32,
        height: 18,
        padding: const EdgeInsets.all(2),
        alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
            color: valor ? c.botao : c.blocoSobre, borderRadius: kTanRaioPeca),
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: valor ? c.botaoTexto : c.painel,
              borderRadius: const BorderRadius.all(Radius.circular(2))),
        ),
      ),
    );
  }
}

/// Seletor segmentado (uma opcao entre poucas).
class TanSegmentado<T> extends StatelessWidget {
  const TanSegmentado(
      {Key? key,
      required this.opcoes,
      required this.valor,
      required this.onChanged})
      : super(key: key);

  final List<(T, String)> opcoes;
  final T valor;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: c.bloco, borderRadius: kTanRaioPeca),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (v, rotulo) in opcoes)
            TanToque(
              onTap: onChanged == null ? null : () => onChanged!(v),
              builder: (context, sobre) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: v == valor
                      ? c.botao
                      : (sobre ? c.blocoSobre : Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
                child: Text(rotulo,
                    style: tanTexto(context,
                        size: 12,
                        peso: v == valor ? FontWeight.w600 : FontWeight.w400,
                        cor: v == valor ? c.botaoTexto : c.texto)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icone clicavel pequeno (barra de titulo, acoes de linha).
class TanIcone extends StatelessWidget {
  const TanIcone(this.icone,
      {Key? key,
      required this.onTap,
      this.dica,
      this.cor,
      this.tamanho = 18,
      this.largura = 34,
      this.fechar = false})
      : super(key: key);

  final IconData icone;
  final VoidCallback? onTap;
  final String? dica;
  final Color? cor;
  final double tamanho;
  final double largura;

  /// Fundo vermelho com o mouse em cima (botao de fechar janela).
  final bool fechar;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return TanToque(
      onTap: onTap,
      dica: dica,
      builder: (context, sobre) => Container(
        width: largura,
        height: fechar ? 40 : largura,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sobre ? (fechar ? const Color(0xFFC42B1C) : c.bloco) : null,
          borderRadius: fechar ? null : kTanRaioPeca,
        ),
        child: Icon(icone,
            size: tamanho,
            color: sobre && fechar ? Colors.white : (cor ?? c.textoVar)),
      ),
    );
  }
}

/// Barra de titulo propria da janela: arrasta a janela, logo, nome e botoes do Windows.
/// Fechar chama windowManager.close(); quem decide esconder/fechar continua sendo o
/// DesktopTab do RustDesk (onWindowClose), que segue montado embaixo.
class TanBarraTitulo extends StatelessWidget {
  const TanBarraTitulo(
      {Key? key,
      this.complemento,
      this.direita,
      this.maximizar = true,
      this.onFechar})
      : super(key: key);

  final String? complemento;
  final Widget? direita;
  final bool maximizar;

  /// No lugar de windowManager.close() (o cliente encerra o programa em vez de esconder).
  final VoidCallback? onFechar;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: c.painel, border: Border(bottom: BorderSide(color: c.linha))),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: kTanRaioPeca,
                        child: SizedBox(
                            width: 22, height: 22, child: loadIcon(22))),
                    const SizedBox(width: 9),
                    Text('TAN! Suporte',
                        style: tanTexto(context,
                            size: 13.5, peso: FontWeight.w700, cor: c.titulo)),
                    if (complemento != null) ...[
                      const SizedBox(width: 8),
                      Text(complemento!,
                          style:
                              tanTexto(context, size: 11.5, cor: c.textoVar)),
                    ],
                    const Spacer(),
                    if (direita != null) direita!,
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),
          TanIcone(Icons.remove_rounded,
              dica: 'Minimizar',
              largura: 44,
              onTap: () => windowManager.minimize()),
          if (maximizar)
            Obx(() => TanIcone(
                  stateGlobal.isMaximized.isTrue
                      ? Icons.filter_none_rounded
                      : Icons.crop_square_rounded,
                  dica: stateGlobal.isMaximized.isTrue
                      ? 'Restaurar'
                      : 'Maximizar',
                  largura: 44,
                  tamanho: 15,
                  onTap: () async {
                    if (await windowManager.isMaximized()) {
                      await windowManager.unmaximize();
                      stateGlobal.setMaximized(false);
                    } else {
                      await windowManager.maximize();
                      stateGlobal.setMaximized(true);
                    }
                  },
                )),
          TanIcone(Icons.close_rounded,
              dica: 'Fechar',
              largura: 46,
              fechar: true,
              onTap: onFechar ?? () => windowManager.close()),
        ],
      ),
    );
  }
}
