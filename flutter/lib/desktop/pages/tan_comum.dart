// TAN! Suporte: pecas visuais das telas do cliente e do tecnico, na linguagem do TAN! Web
// (TANWeb/lib/tema/tema.dart e lib/widgets/blocos.dart): fundo cinza-azulado, paineis brancos de
// canto quase reto, titulo com barrinha laranja, campo como bloco chapado sem contorno, botao azul
// cheio, estado como quadradinho + texto, fonte Inter.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';

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

/// Estado como quadradinho colorido + texto.
class TanEstado extends StatelessWidget {
  const TanEstado(this.status, {Key? key}) : super(key: key);

  final TanStatus status;

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    final (cor, texto) = switch (status) {
      TanStatus.pronto => (c.ok, 'Pronto para conectar'),
      TanStatus.conectando => (c.pend, 'Conectando ao servidor...'),
      TanStatus.offline => (c.bad, 'Sem conexão com o servidor'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: cor),
        const SizedBox(width: 7),
        Text(texto, style: tanTexto(context, size: 12, cor: c.textoVar)),
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
