// TAN! Suporte: aplica a linguagem do TAN! Web ao tema inteiro do RustDesk (MyTheme em common.dart),
// para que Configuracoes, dialogos e a janela do cliente durante o acesso herdem fonte, cores e cantos
// sem reescrever cada tela.
import 'package:flutter/material.dart';

const _fonte = 'Inter';
const _azul = Color(0xFF1F3B73);
const _laranja = Color(0xFFF26522);
const _raioPeca = BorderRadius.all(Radius.circular(3));
const _raioBloco = BorderRadius.all(Radius.circular(4));

ThemeData tanTema(ThemeData t) {
  final escuro = t.brightness == Brightness.dark;
  final fundo = escuro ? const Color(0xFF111317) : const Color(0xFFE1E6EE);
  final painel = escuro ? const Color(0xFF1C1F25) : Colors.white;
  final bloco = escuro ? const Color(0xFF272A31) : const Color(0xFFD8E1ED);
  final linha = escuro ? const Color(0xFF363A43) : const Color(0xFFC7D6EB);
  final texto = escuro ? const Color(0xFFE3E5EA) : const Color(0xFF253047);
  final destaque = escuro ? const Color(0xFFC9CED8) : _azul;
  final sobreDestaque = escuro ? const Color(0xFF1B1F27) : Colors.white;

  const semBorda = OutlineInputBorder(
      borderSide: BorderSide.none, borderRadius: _raioPeca);
  final formaPeca = const RoundedRectangleBorder(borderRadius: _raioPeca);

  return t.copyWith(
    scaffoldBackgroundColor: painel,
    dialogBackgroundColor: painel,
    cardColor: bloco,
    dividerColor: linha,
    hoverColor: bloco,
    textTheme: t.textTheme.apply(fontFamily: _fonte, bodyColor: texto),
    primaryTextTheme: t.primaryTextTheme.apply(fontFamily: _fonte),
    colorScheme: t.colorScheme.copyWith(
      primary: destaque,
      onPrimary: sobreDestaque,
      secondary: destaque,
      background: fundo,
      surface: painel,
    ),
    dialogTheme: t.dialogTheme.copyWith(
      elevation: 8,
      shape: RoundedRectangleBorder(
          borderRadius: _raioBloco, side: BorderSide(color: linha)),
    ),
    inputDecorationTheme: t.inputDecorationTheme.copyWith(
      fillColor: bloco,
      filled: true,
      border: semBorda,
      enabledBorder: semBorda,
      disabledBorder: semBorda,
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _laranja, width: 1.5),
          borderRadius: _raioPeca),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: destaque,
        foregroundColor: sobreDestaque,
        elevation: 0,
        textStyle:
            const TextStyle(fontFamily: _fonte, fontWeight: FontWeight.w600),
        shape: formaPeca,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: bloco,
        foregroundColor: texto,
        side: BorderSide.none,
        textStyle: const TextStyle(fontFamily: _fonte),
        shape: formaPeca,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: (t.textButtonTheme.style ?? const ButtonStyle()).copyWith(
        foregroundColor: MaterialStatePropertyAll(destaque),
        textStyle: const MaterialStatePropertyAll(
            TextStyle(fontFamily: _fonte, fontWeight: FontWeight.w600)),
        shape: MaterialStatePropertyAll(formaPeca),
      ),
    ),
    popupMenuTheme: t.popupMenuTheme.copyWith(
      color: painel,
      shape: RoundedRectangleBorder(
          borderRadius: _raioBloco, side: BorderSide(color: linha)),
    ),
    tabBarTheme: t.tabBarTheme.copyWith(
      labelColor: destaque,
      indicatorColor: _laranja,
    ),
  );
}
