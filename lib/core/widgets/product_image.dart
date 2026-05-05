import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.productName,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: height,
            width: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final cfg = _resolve(productName);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cfg.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(cfg.icon, size: 52, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(height: 8),
          Text(
            cfg.label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _IconCfg _resolve(String name) {
    final n = name.toLowerCase();
    if (n.contains('watch') || n.contains('smartwatch')) {
      return _IconCfg(Icons.watch, [const Color(0xFFC62828), const Color(0xFF7B0000)], 'SMARTWATCH');
    }
    if (n.contains('laptop') || n.contains('lenovo') || n.contains('portátil')) {
      return _IconCfg(Icons.laptop_mac, [const Color(0xFF1565C0), const Color(0xFF0D47A1)], 'LAPTOP');
    }
    if (n.contains('samsung') || n.contains('galaxy') || n.contains('iphone') || n.contains('smartphone')) {
      return _IconCfg(Icons.smartphone, [const Color(0xFF6A1B9A), const Color(0xFF4A148C)], 'SMARTPHONE');
    }
    if (n.contains('audífono') || n.contains('headphone') || n.contains('sony') || n.contains('wh-')) {
      return _IconCfg(Icons.headphones, [const Color(0xFF00695C), const Color(0xFF004D40)], 'HEADPHONES');
    }
    if (n.contains('ipad') || n.contains('tablet')) {
      return _IconCfg(Icons.tablet_mac, [const Color(0xFF00838F), const Color(0xFF006064)], 'TABLET');
    }
    if (n.contains('monitor')) {
      return _IconCfg(Icons.monitor, [const Color(0xFF37474F), const Color(0xFF263238)], 'MONITOR');
    }
    if (n.contains('teclado') || n.contains('keyboard') || n.contains('redragon')) {
      return _IconCfg(Icons.keyboard, [const Color(0xFFBF360C), const Color(0xFF870000)], 'KEYBOARD');
    }
    if (n.contains('mouse') || n.contains('logitech')) {
      return _IconCfg(Icons.mouse, [const Color(0xFF212121), const Color(0xFF424242)], 'MOUSE');
    }
    if (n.contains('ssd') || n.contains('disco') || n.contains(' wd ') || n.contains('storage')) {
      return _IconCfg(Icons.storage, [const Color(0xFF2E7D32), const Color(0xFF1B5E20)], 'STORAGE');
    }
    return _IconCfg(Icons.devices_other, [const Color(0xFF1565C0), const Color(0xFF0A3D62)], 'PRODUCTO');
  }
}

class _IconCfg {
  final IconData icon;
  final List<Color> colors;
  final String label;
  const _IconCfg(this.icon, this.colors, this.label);
}
