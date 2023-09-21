import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class WinningLinePainter extends CustomPainter {
  final List<int> winningPath;
  double _progress;

  WinningLinePainter(this.winningPath, this._progress);

  // Animates the line
  void animate() {
    _progress += 0.01;
    if (_progress > 1.0) {
      _progress = 1.0;
    }
  }

  // Undraws the line
  void erase() {
    _progress -= 0.01;
    if (_progress < 0.0) {
      _progress = 0.0;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (winningPath.length != 3) {
      return; // Invalid winning path
    }

    final Paint paint = Paint()
      ..color = Colors.red // Color of the line
      ..strokeWidth = 5.0; // Width of the line

    // Calculate the positions of the winning line based on the winning cells
    final startCellX = winningPath[0] % 3;
    final startCellY = winningPath[0] ~/ 3;
    final endCellX = winningPath[2] % 3;
    final endCellY = winningPath[2] ~/ 3;

    final startPoint = Offset(
      (startCellX + 0.5) * size.width / 3,
      (startCellY + 0.8) * size.width / 3,
    );

    final endPoint = Offset(
      ((endCellX + 0.5) * size.width / 3 * _progress) - _progress,
      ((endCellY + 0.8) * size.width / 3 * _progress) - _progress,
    );

    // Draw the partial line
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(WinningLinePainter oldDelegate) => true;


}