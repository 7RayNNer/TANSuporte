// TAN! Suporte: tela "Sobre". Mantem o aviso da licenca AGPL-3.0 com o link do codigo-fonte,
// como a licenca exige, sem citar o projeto de origem na interface.
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/formatter/id_formatter.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _codigoFonte = 'https://github.com/7RayNNer/TANSuporte';
const _servidor = 'suporteremoto.tansistemas.com.br';

class TanSobre extends StatefulWidget {
  const TanSobre({Key? key}) : super(key: key);

  @override
  State<TanSobre> createState() => _TanSobreState();
}

class _TanSobreState extends State<TanSobre> {
  bool _procurando = false;

  Future<void> _procurar() async {
    setState(() => _procurando = true);
    bind.mainGetSoftwareUpdateUrl();
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    setState(() => _procurando = false);
    if (stateGlobal.updateUrl.value.isEmpty) {
      showToast('Você já está na versão mais nova.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    final versao = bind.mainGetBuildinOption(key: 'tan-versao');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                    borderRadius: kTanRaioBloco,
                    child: SizedBox(width: 52, height: 52, child: loadIcon(52))),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TAN! Suporte',
                        style: tanTexto(context,
                            size: 18, peso: FontWeight.w700, cor: c.titulo)),
                    const SizedBox(height: 2),
                    Text('Acesso remoto da TAN!',
                        style: tanTexto(context, size: 12.5, cor: c.textoVar)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            TanLinha(
                rotulo: 'Versão',
                direita: Text(versao, style: tanTexto(context, size: 13))),
            TanLinha(
                rotulo: 'Servidor',
                direita: Text(_servidor,
                    style: tanTexto(context, size: 13, cor: c.textoVar))),
            TanLinha(
                rotulo: 'Este computador',
                direita: SelectableText(formatID(gFFI.serverModel.serverId.text),
                    style: tanTexto(context, size: 13))),
            TanLinha(
              rotulo: 'Atualizações',
              ultima: true,
              direita: Obx(() => stateGlobal.updateUrl.value.isNotEmpty
                  ? TanLink('Baixar a versão nova',
                      onTap: () =>
                          launchUrlString(stateGlobal.updateUrl.value))
                  : _procurando
                      ? Text('Procurando...',
                          style: tanTexto(context, size: 12, cor: c.dica))
                      : TanLink('Procurar agora', onTap: _procurar)),
            ),
            const SizedBox(height: 28),
            Text('Software livre sob a licença AGPL-3.0.',
                style: tanTexto(context, size: 11.5, cor: c.dica)),
            const SizedBox(height: 2),
            Row(
              children: [
                Text('Código-fonte: ',
                    style: tanTexto(context, size: 11.5, cor: c.dica)),
                TanLink('github.com/7RayNNer/TANSuporte',
                    onTap: () => launchUrlString(_codigoFonte)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
