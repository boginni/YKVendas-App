import 'package:flutter/material.dart';

import '../../../../../api/common/custom_widgets/custom_text.dart';

class ContainerLoading extends StatelessWidget {
  const ContainerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              TextNormal('Carregando Dados'),
            ],
          ),
        ),
      ),
    );
  }
}
