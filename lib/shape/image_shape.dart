/// This is a Dart code file named image_shape.dart.
///
/// Summary:
/// This file defines a class called ImageShape, which is a subclass of TextBoxShape. It represents a shape that displays an image.
/// The ImageShape class has properties for the image, border color, background color, location, size, text, text alignment, text style, z-index, and border radius.
/// The constructor initializes the properties of the ImageShape object, including setting the size based on the dimensions of the image.
/// The drawObject method overrides the parent class's method to draw the image on the canvas using the provided paint object.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:magic_canvas_with_image_export/magic_canvas_with_image_export.dart';

class ImageShape extends AbstractShape {
  ui.Image image;
  Radius borderRadius;

  ImageShape({
    required this.image,
    this.borderRadius = Radius.zero,
    super.color,
    super.location,
    super.size,
    super.zIndex,
    super.reactSize,
  }) {
    size = Size(
      image.width.toDouble() > 240 ? 240 : image.width.toDouble(),
      image.height.toDouble() > 240 ? 240 : image.height.toDouble(),
    );
  }

  // @override
  // void draw(Canvas canvas, Size boardSize) {
  //   final Paint paint = Paint();
  //   canvas.drawImageNine(
  //     image,
  //     Rect.zero,
  //     Rect.fromCenter(center: center, width: size.width, height: size.height),
  //     paint,
  //   );
  // }

  @override
  void draw(Canvas canvas, Size boardSize) {
    final Paint paint = Paint();
    drawObject(canvas, paint);
    drawDecorate(canvas, paint);
    drawHighlight(canvas, paint);
    drawInteractivePoint(canvas, paint);
  }

  void drawHighlight(Canvas canvas, Paint paint) {
    if (isHighlight || isSelected) {
      paint.color = Colors.blue;
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(
        Rect.fromPoints(
          location,
          location.translate(size.width, size.height),
        ),
        paint,
      );
    }
  }

  void drawObject(Canvas canvas, Paint paint) {
    canvas.drawImageNine(
      image,
      Rect.zero,
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      paint,
    );
  }

  void drawDecorate(Canvas canvas, Paint paint) {
    // if (borderColor != null) {
    //   paint.color = borderColor!;
    //   paint.style = PaintingStyle.stroke;
    //   drawObject(canvas, paint);
    // }
  }

  void drawInteractivePoint(Canvas canvas, Paint paint) {
    if (isSelected) {
      for (var resizePoint in resizePoints) {
        paint.color = Colors.blue;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          resizePoint.offset,
          5,
          paint,
        );
      }
      for (var rotatePoint in rotatePoints) {
        paint.color = Colors.blue;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1;
        canvas.drawLine(
          rotatePoint.offset,
          rotatePoint.anchorOffset,
          paint,
        );
        const icon = Icons.rotate_right;
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, rotatePoint.offset.translate(-10, -10));
      }
      for (var removePoint in removePoints) {
        const icon = Icons.remove_circle;
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, removePoint.translate(-10, -10));
      }
    }
  }

  @override
  List<RotatePoint> get rotatePoints => [
        RotatePoint(
          offset: location.translate(size.width / 2, -30),
          anchorOffset: location.translate(size.width / 2, 0),
        ),
      ];

  @override
  List<ResizePoint> get resizePoints => [
        //middle left
        ResizePoint(
          offset: location.translate(0, size.height / 2),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTR = location
                .translate(size.width, 0)
                .rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedBL =
                Offset(newMouseDeRotated.dx, location.dy + size.height)
                    .rotate(angle: angle, center: center);
            Size newSize = Size(
                location.dx + size.width - newMouseDeRotated.dx, size.height);
            Offset newCenter = Offset(
              (rotatedTR.dx + rotatedBL.dx) / 2,
              (rotatedTR.dy + rotatedBL.dy) / 2,
            );

            Offset newTR = rotatedTR.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newTR.translate(-size.width, 0);
          },
        ),
        //middle top
        ResizePoint(
          offset: location.translate(size.width / 2, 0),
          onResize: (oldMouse, newMouse) {
            Offset rotatedBL = location
                .translate(0, size.height)
                .rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedTR =
                Offset(location.dx + size.width, newMouseDeRotated.dy)
                    .rotate(angle: angle, center: center);
            Size newSize = Size(
                size.width, location.dy + size.height - newMouseDeRotated.dy);
            Offset newCenter = Offset(
              (rotatedBL.dx + rotatedTR.dx) / 2,
              (rotatedBL.dy + rotatedTR.dy) / 2,
            );
            Offset newBL = rotatedBL.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newBL.translate(0, -size.height);
          },
        ),

        //middle right
        ResizePoint(
          offset: location.translate(size.width, size.height / 2),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTL = location.rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedBR =
                Offset(newMouseDeRotated.dx, location.dy + size.height)
                    .rotate(angle: angle, center: center);
            Size newSize =
                Size(newMouseDeRotated.dx - location.dx, size.height);
            Offset newCenter = Offset(
              (rotatedTL.dx + rotatedBR.dx) / 2,
              (rotatedTL.dy + rotatedBR.dy) / 2,
            );
            Offset newTL = rotatedTL.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newTL;
          },
        ),
        //middle bottom
        ResizePoint(
          offset: location.translate(size.width / 2, size.height),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTL = location.rotate(center: center, angle: angle);
            Offset newMouseDeRotated =
                newMouse.rotate(center: center, angle: -angle);
            Offset rotatedBR =
                Offset(location.dx + size.width, newMouseDeRotated.dy)
                    .rotate(angle: angle, center: center);
            Size newSize = Size(size.width, newMouseDeRotated.dy - location.dy);
            Offset newCenter = Offset(
              (rotatedTL.dx + rotatedBR.dx) / 2,
              (rotatedTL.dy + rotatedBR.dy) / 2,
            );
            Offset newTL = rotatedTL.rotate(
              center: newCenter,
              angle: -angle,
            );
            size = newSize;
            location = newTL;
          },
        ),
        //top left
        ResizePoint(
          offset: location,
          onResize: (oldMouse, newMouse) {
            Offset rotatedBR = location
                .translate(size.width, size.height)
                .rotate(center: center, angle: angle);

            Offset newCenter = Offset(
              (rotatedBR.dx + newMouse.dx) / 2,
              (rotatedBR.dy + newMouse.dy) / 2,
            );

            Offset newTL = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );

            Offset newBR = rotatedBR.rotate(center: newCenter, angle: -angle);
            location = newTL;
            size = Size(newBR.dx - newTL.dx, newBR.dy - newTL.dy);
          },
        ),
        //top right
        ResizePoint(
          offset: location.translate(size.width, 0),
          onResize: (oldMouse, newMouse) {
            Offset rotatedBL = location
                .translate(0, size.height)
                .rotate(center: center, angle: angle);

            Offset newCenter = Offset(
              (rotatedBL.dx + newMouse.dx) / 2,
              (rotatedBL.dy + newMouse.dy) / 2,
            );

            Offset newTR = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );
            Offset newBL = rotatedBL.rotate(center: newCenter, angle: -angle);

            location = Offset(newBL.dx, newTR.dy);

            size = Size(newTR.dx - location.dx, newBL.dy - location.dy);
          },
        ),

        //bottom left
        ResizePoint(
          offset: location.translate(0, size.height),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTR = location
                .translate(size.width, 0)
                .rotate(center: center, angle: angle);

            Offset newCenter = Offset(
              (rotatedTR.dx + newMouse.dx) / 2,
              (rotatedTR.dy + newMouse.dy) / 2,
            );

            Offset newBL = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );
            Offset newTR = rotatedTR.rotate(center: newCenter, angle: -angle);

            location = Offset(newBL.dx, newTR.dy);

            size = Size(newTR.dx - location.dx, newBL.dy - location.dy);
          },
        ),
        //bottom right
        ResizePoint(
          offset: location.translate(size.width, size.height),
          onResize: (oldMouse, newMouse) {
            Offset rotatedTL = location.rotate(center: center, angle: angle);
            Offset newCenter = Offset(
              (rotatedTL.dx + newMouse.dx) / 2,
              (rotatedTL.dy + newMouse.dy) / 2,
            );

            Offset newTL = rotatedTL.rotate(
              center: newCenter,
              angle: -angle,
            );

            Offset newBR = newMouse.rotate(
              center: newCenter,
              angle: -angle,
            );
            location = newTL;
            size = Size(newBR.dx - newTL.dx, newBR.dy - newTL.dy);
          },
        ),
      ];

  @override
  List<Offset> get removePoints => [
        location.translate(size.width + 20, -20),
      ];
}
