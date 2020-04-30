import 'dart:math';
import 'package:flutter/material.dart';

import 'syntaxes/base.dart';
import 'syntaxes/index.dart';

class SyntaxView extends StatefulWidget {
  SyntaxView(
      {@required this.code,
      @required this.syntax,
      this.syntaxTheme,
      this.withZoom,
      this.withLinesCount});

  final String code;
  final Syntax syntax;
  final bool withZoom;
  final bool withLinesCount;
  final SyntaxTheme syntaxTheme;

  @override
  State<StatefulWidget> createState() => SyntaxViewState();
}

class SyntaxViewState extends State<SyntaxView> {
  /// Zoom Controls
  double textScaleFactor = 1.0;
  //my making
  final double _basefontSize = 12;
  double _fontSize = 12;
  double _fontScale = 1.0;
  double _baseFontScale = 1.0;
  @override
  Widget build(BuildContext context) {
    assert(widget.code != null,
        "Code Content must not be null.\n===| if you are loading a String from assets, make sure you declare it in pubspec.yaml |===");
    assert(widget.syntax != null,
        "Syntax must not be null. select a Syntax by calling Syntax.(Language)");

    final int numLines = (widget.withLinesCount ?? true)
        ? '\n'.allMatches(widget.code).length
        : 0;

    return Stack(alignment: AlignmentDirectional.bottomEnd, children: <Widget>[
      Container(
          padding: (widget.withLinesCount ?? true)
              ? EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0)
              : EdgeInsets.only(left: 0, top: 0),
          color: (widget.syntaxTheme ?? SyntaxTheme.dracula()).backgroundColor,
          constraints: BoxConstraints.expand(),
          child: Scrollbar(
              child: SingleChildScrollView(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GestureDetector(
                          onScaleStart: (ScaleStartDetails scaleStartDetails) {
                            _baseFontScale = _fontScale;
                          },
                          onScaleUpdate:
                              (ScaleUpdateDetails scaleUpdateDetails) {
                            setState(() {
                              _fontScale =
                                  (_baseFontScale * scaleUpdateDetails.scale)
                                      .clamp(0.6, 3);
                              _fontSize = _fontScale * _basefontSize;
                            });
                          },

                          /// Lines Count in the left with Code view
                          child: (widget.withLinesCount ?? true)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(children: <Widget>[
                                      for (int i = 0; i <= numLines; i++)
                                        RichText(
                                            textScaleFactor: textScaleFactor,
                                            text: TextSpan(
                                                style: TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: _fontSize,
                                                    color:
                                                        (widget.syntaxTheme ??
                                                                SyntaxTheme
                                                                    .dracula())
                                                            .linesCountColor),
                                                text:(i==0)?"": "$i"))
                                    ]),
                                    VerticalDivider(width: 1),
                                    RichText(
                                      textScaleFactor: textScaleFactor,
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: _fontSize),
                                        children: <TextSpan>[
                                          getSyntax(widget.syntax,
                                                  widget.syntaxTheme)
                                              .format(widget.code)
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              :

                              /// Only Code view
                              RichText(
                                  textScaleFactor: textScaleFactor,
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: _fontSize),
                                    children: <TextSpan>[
                                      getSyntax(
                                              widget.syntax, widget.syntaxTheme)
                                          .format(widget.code)
                                    ],
                                  ),
                                )))))),

      /// Zoom Controls
      if (widget.withZoom ?? false)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.zoom_out,
                    color: (widget.syntaxTheme ?? SyntaxTheme.dracula())
                        .zoomIconColor),
                onPressed: () => setState(() {
                      if (mounted)
                        textScaleFactor = max(0.8, textScaleFactor - 0.1);
                    })),
            IconButton(
                icon: Icon(Icons.zoom_in,
                    color: (widget.syntaxTheme ?? SyntaxTheme.dracula())
                        .zoomIconColor),
                onPressed: () => setState(() {
                      if (mounted) {
                        if (textScaleFactor <= 4.0)
                          textScaleFactor += 0.1;
                        else
                          print(
                              "Maximun zoomable scale (4.0) has been reached. more zooming can cause a crash.");
                      }
                    })),
          ],
        )
    ]);
  }
}
