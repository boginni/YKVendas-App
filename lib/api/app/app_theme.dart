import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppTheme {
  AppTheme() {
    textTheme = TextTheme(colorTheme);

    buttonStyle = TextButton.styleFrom(
      backgroundColor: colorTheme.primaryColor, // Text Color
    );

    buttonStyle2 = TextButton.styleFrom(
        backgroundColor: colorTheme.primaryColorBackground // Text Color
        );
  }

  factory AppTheme.of(BuildContext context) {
    return context.read<AppTheme>();
  }

  final ColorTheme colorTheme = ColorTheme();

  late final TextTheme textTheme;

  late final ButtonStyle buttonStyle;
  late final ButtonStyle buttonStyle2;

  final EdgeInsets telaPadding =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
}

class TextTheme {
  final ColorTheme _cor;
  final String _defaultFont = 'Open Sans';

  TextTheme(this._cor);

  TextStyle title({Color? color, String? font}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? _cor.text));
  }

  TextStyle subTitle({Color? color, String? font, double size = 18}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: color ?? _cor.text));
  }

  TextStyle subTitle2({Color? color, String? font, double size = 16}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: color ?? _cor.primaryColorBackground));
  }

  TextStyle title2({Color? color, String? font, double size = 16}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: color ?? _cor.text.withOpacity(0.5)));
  }

  TextStyle title3({Color? color, String? font, double size = 14}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic,
            color: color ?? _cor.text.withOpacity(0.5)));
  }

  TextStyle body({Color? color, String? font, double? fontSize}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(color: color ?? _cor.text, fontSize: fontSize));
  }

  TextStyle detail({Color? color, String? font}) {
    return GoogleFonts.getFont(font ?? _defaultFont,
        textStyle: TextStyle(color: color ?? _cor.text, fontSize: 10));
  }
}

class ColorTheme {
  Color primaryColor = Colors.blueAccent;
  Color secondaryColor = Colors.grey[200]!;

  // Color primaryColor = Colors.grey[500]!;
  // Color secondary = Colors.grey[800]!;

  Color primaryColorBackground = Colors.white;
  Color secondaryColorBackground = Colors.blue[100]!;

  Color text = Colors.black;

  // Color text = Colors.white;
  Color textBg = Colors.white;

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

class AppSize {
  AppSize.of(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    bigScreen = width > 1600;
    smallScreen = width < 1300;
    poor = width < 850;
    mobile = width < 720;
  }

  late final double width;

  late final bool bigScreen;

  late final bool smallScreen;

  late final bool poor;

  late final bool mobile;
}
