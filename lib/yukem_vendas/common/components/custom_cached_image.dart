import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart' as pp;

import '../../../api/models/interface/queue_action.dart';

class CustomCachedImage extends StatefulWidget {
  final String iconLink;
  final bool createThumb;
  final bool download;
  final String ambiente;
  final String name;
  final String iconName;

  final Widget? placeHolder;
  final Widget? failHorlder;

  final String link;

  final bool waitTurn;

  const CustomCachedImage({
    Key? key,
    required this.ambiente,
    required this.name,
    this.placeHolder,
    this.failHorlder,
    required this.link,
    this.createThumb = false,
    this.download = true,
    this.iconName = '',
    this.iconLink = '',
    this.waitTurn = true,
  });

  @override
  State<CustomCachedImage> createState() => _CustomCachedImageState();
}

class _CustomCachedImageState extends State<CustomCachedImage>
    implements QueueAction {
  bool first = true;

  File? imgFile;

  Future<File> getImagem() async {
    first = false;

    final folder = (await pp.getTemporaryDirectory()).path;
    final path = '$folder/${widget.ambiente}';

    final dir = Directory(path);
    final filePath = '$path/${widget.name}';

    try {
      // throw Exception();
      File imgFile = File(filePath);
      if (imgFile.existsSync() && imgFile.lengthSync() > 200) {
        return imgFile;
      }

      throw Exception();
    } catch (e) {
      if (!widget.download) {
        throw Exception('Não será feito download');
      }

      if (!dir.existsSync()) {
        dir.createSync();
      }

      Response response = await get(Uri.parse(widget.link),
          headers: {'Accept-Encoding': 'gzip, deflate, br'});

      if (response.bodyBytes.isEmpty) {
        throw Exception('invalid response');
      }

      File imgFile = File(filePath);
      imgFile.writeAsBytesSync(response.bodyBytes);

      if (widget.createThumb) {

        response = await get(Uri.parse(widget.iconLink), headers: {
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive'
        });

        if (response.bodyBytes.isEmpty) {
          throw Exception('invalid response');
        }

        File imgthumbFile = File('$path/${widget.iconName}');
        imgthumbFile.writeAsBytesSync(response.bodyBytes);
      }

      return imgFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.waitTurn || finished ? null : doTurn(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (onFail) {
          return widget.failHorlder ?? Container();
        }

        if (finished) {
          return Image.file(imgFile!);
        }

        return widget.placeHolder ?? const CircularProgressIndicator();
      },
    );
  }

  @override
  bool onTurn = false;

  @override
  void initState() {
    super.initState();
    QueueAction.addListener(this);
  }

  bool finished = false;
  bool onFail = false;

  @override
  Future<void> doTurn() async {
    onTurn = true;

    try {
      imgFile = await getImagem();
    } catch (e) {
      onFail = true;
    }

    QueueAction.removeListener(this);
    finished = true;
    onTurn = false;
    setState(() {});
  }
}
