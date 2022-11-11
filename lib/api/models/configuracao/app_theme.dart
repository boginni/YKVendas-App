import 'dart:ui';

@Deprecated('Usar AppTheme')
class AppThemeOld {
  final Color primaryColor;
  final Color secondaryColor;
  final Color buttonColor;
  final Color textTitleColor;
  final Color textNormalColor;

  AppThemeOld(
      {required this.primaryColor,
      required this.secondaryColor,
      required this.buttonColor,
      required this.textTitleColor,
      required this.textNormalColor});

  factory AppThemeOld.int() {
    return AppThemeOld(
      primaryColor: const Color(0x00000000),
      secondaryColor: const Color(0x00000000),
      buttonColor: const Color(0x00000000),
      textTitleColor: const Color(0x00000000),
      textNormalColor: const Color(0x00000000),
    );
  }

  factory AppThemeOld.fromDefault() {
    Color parse(String hexString) {
      int color = int.parse(hexString, radix: 16);
      return Color(color);
    }

    return AppThemeOld(
      primaryColor: parse('FF00DDFF'),
      secondaryColor: parse('FFAAFFDD'),
      buttonColor: const Color(0x00000000),
      textTitleColor: const Color(0x00000000),
      textNormalColor: const Color(0x00000000),
    );
  }
}
