import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/desktop/pages/tan_comum.dart';
import 'package:flutter_hbb/desktop/widgets/tabbar_widget.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:window_manager/window_manager.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({Key? key}) : super(key: key);

  @override
  State<InstallPage> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  final tabController = DesktopTabController(tabType: DesktopTabType.main);

  _InstallPageState() {
    // TAN! Suporte: sem a barra de abas do RustDesk; a tela desenha a TanBarraTitulo.
    stateGlobal.showTabBar.value = false;
    Get.put<DesktopTabController>(tabController);
    const label = "install";
    tabController.add(TabInfo(
        key: label,
        label: label,
        closable: false,
        page: _InstallPageBody(
          key: const ValueKey(label),
        )));
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<DesktopTabController>();
  }

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      resizeEdgeSize: stateGlobal.resizeEdgeSize.value,
      enableResizeEdges: windowManagerEnableResizeEdges,
      child: Container(
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: DesktopTab(controller: tabController)),
      ),
    );
  }
}

class _InstallPageBody extends StatefulWidget {
  const _InstallPageBody({Key? key}) : super(key: key);

  @override
  State<_InstallPageBody> createState() => _InstallPageBodyState();
}

class _InstallPageBodyState extends State<_InstallPageBody>
    with WindowListener {
  late final TextEditingController controller;
  final RxBool startmenu = true.obs;
  final RxBool desktopicon = true.obs;
  final RxBool printer = false.obs;
  final RxBool showProgress = false.obs;
  final RxBool btnEnabled = true.obs;

  // todo move to theme.
  final buttonStyle = OutlinedButton.styleFrom(
    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
  );

  _InstallPageBodyState() {
    controller = TextEditingController(text: bind.installInstallPath());
    final installOptions = jsonDecode(bind.installInstallOptions());
    startmenu.value = installOptions['STARTMENUSHORTCUTS'] != '0';
    desktopicon.value = installOptions['DESKTOPSHORTCUTS'] != '0';
    printer.value = installOptions['PRINTER'] == '1';
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    // TAN! Suporte: a tela da TAN e compacta
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await windowManager.setSize(const Size(520, 440));
      await windowManager.center();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    gFFI.close();
    super.onWindowClose();
    windowManager.setPreventClose(false);
    windowManager.close();
  }

  InkWell Option(RxBool option, {String label = ''}) {
    return InkWell(
      // todo mouseCursor: "SystemMouseCursors.forbidden" or no cursor on btnEnabled == false
      borderRadius: BorderRadius.circular(6),
      onTap: () => btnEnabled.value ? option.value = !option.value : null,
      child: Row(
        children: [
          Obx(
            () => Checkbox(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              value: option.value,
              onChanged: (v) =>
                  btnEnabled.value ? option.value = !option.value : null,
            ).marginOnly(right: 8),
          ),
          Expanded(
            child: Text(translate(label)),
          ),
        ],
      ),
    );
  }

  // TAN! Suporte: tela propria de instalacao do acesso fixo. A logica (opcoes, caminho,
  // install(), fechar) continua a do RustDesk; so o desenho e da TAN.
  @override
  Widget build(BuildContext context) {
    final c = TanCores.of(context);
    opcao(RxBool valor, String texto) => Obx(() => TanToque(
          onTap: btnEnabled.value ? () => valor.value = !valor.value : null,
          builder: (context, sobre) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(
                    valor.value
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 19,
                    color: valor.value ? c.titulo : c.dica),
                const SizedBox(width: 9),
                Text(texto, style: tanTexto(context, size: 13)),
              ],
            ),
          ),
        ));
    return Container(
      color: c.fundo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TanBarraTitulo(maximizar: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TanPainel(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TanTitulo('Instalar acesso fixo', size: 15),
                    const SizedBox(height: 10),
                    Text(
                        'Depois de instalado, o técnico da TAN! acessa este computador mesmo sem ninguém por perto, usando uma senha fixa. Ele inicia junto com o Windows e se atualiza sozinho.',
                        style: tanTexto(context,
                            size: 12.5, cor: c.textoVar)
                            .copyWith(height: 1.5)),
                    const SizedBox(height: 18),
                    const TanRotulo('Pasta'),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: controller,
                              readOnly: true,
                              style: tanTexto(context, size: 12.5),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Obx(() => TanToque(
                              onTap: btnEnabled.value ? selectInstallPath : null,
                              builder: (context, sobre) => Container(
                                height: 38,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: sobre ? c.blocoSobre : c.bloco,
                                    borderRadius: kTanRaioPeca),
                                child: Text('Alterar',
                                    style: tanTexto(context,
                                        size: 12.5,
                                        peso: FontWeight.w600,
                                        cor: c.titulo)),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    opcao(desktopicon, 'Atalho na área de trabalho'),
                    opcao(startmenu, 'Atalho no menu Iniciar'),
                    const Spacer(),
                    Obx(() => showProgress.value
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: c.titulo)),
                                const SizedBox(width: 10),
                                Text('Instalando... o Windows vai pedir permissão.',
                                    style: tanTexto(context,
                                        size: 12, cor: c.textoVar)),
                              ],
                            ),
                          )
                        : const SizedBox.shrink()),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TanToque(
                              onTap: btnEnabled.value
                                  ? () => windowManager.close()
                                  : null,
                              builder: (context, sobre) => Container(
                                height: 38,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: sobre ? c.blocoSobre : c.bloco,
                                    borderRadius: kTanRaioPeca),
                                child: Text('Cancelar',
                                    style: tanTexto(context, size: 13)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TanBotao(
                                texto: 'Instalar',
                                icone: Icons.download_rounded,
                                height: 38,
                                onTap: btnEnabled.value ? install : () {}),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void install() {
    do_install() {
      btnEnabled.value = false;
      showProgress.value = true;
      String args = '';
      if (startmenu.value) args += ' startmenu';
      if (desktopicon.value) args += ' desktopicon';
      if (printer.value) args += ' printer';
      bind.installInstallMe(options: args, path: controller.text);
    }

    do_install();
  }

  void selectInstallPath() async {
    String? install_path = await FilePicker.platform
        .getDirectoryPath(initialDirectory: controller.text);
    if (install_path != null) {
      controller.text = join(install_path, await bind.mainGetAppName());
    }
  }
}
