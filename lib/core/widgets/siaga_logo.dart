import 'package:flutter/material.dart';

/// Lambang Kementerian Dalam Negeri. [height] menentukan ukuran; rasio 134:170.
class SiagaLogo extends StatelessWidget {
  const SiagaLogo({super.key, this.height = 84});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height * 0.08),
      child: Image.asset(
        'assets/images/kemendagri_logo.png',
        height: height,
        fit: BoxFit.contain,
        semanticLabel: 'Lambang Kementerian Dalam Negeri',
      ),
    );
  }
}
