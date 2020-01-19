// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

enum _Element { background, text }

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  var prevHour;
  var prevMinute;
  DateTime _currentTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _mover(true);
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      colonColor = colors[_Element.text];
      hourColor1 = colors[_Element.text];
      hourColor2 = colors[_Element.text];
      minuteColor1 = colors[_Element.text];
      minuteColor2 = colors[_Element.text];
    });
    if (widget.model.is24HourFormat != is24hour) {
      _mover(false);
      setState(() {
        is24hour = widget.model.is24HourFormat;
      });
    }
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _currentTime.second) -
            Duration(milliseconds: _currentTime.millisecond),
        _updateTime,
      );
    });
    if (init == false) {
      _mover(false);
    } else {
      setState(() {
        init = false;
      });
    }
  }

  Future _mover(bool isInitial) async {
    var hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
        .format(_currentTime);
    var minute = DateFormat('mm').format(_currentTime);
    hour = int.parse(hour).toRadixString(16).length == 2
        ? int.parse(hour).toRadixString(16)
        : "0" + int.parse(hour).toRadixString(16);
    minute = int.parse(minute).toRadixString(16).length == 2
        ? int.parse(minute).toRadixString(16)
        : "0" + int.parse(minute).toRadixString(16);
    if (isInitial) {
      await _initlizer();
      _updateTime();
      setState(() {
        is24hour = widget.model.is24HourFormat;
        hourToShow = hour;
        minuteToShow = minute;
      });
      _updateModel();
      setState(() {
        isReady = true;
      });
    } else {
      var prevMinute1 = int.parse(prevMinute).toRadixString(16).length == 2
          ? int.parse(prevMinute).toRadixString(16)
          : "0" + int.parse(prevMinute).toRadixString(16);
      var prevHour1 = int.parse(prevHour).toRadixString(16).length == 2
          ? int.parse(prevHour).toRadixString(16)
          : "0" + int.parse(prevHour).toRadixString(16);
      if (hour != prevHour1) {
        if (hour.substring(0, 1) != prevHour1.substring(0, 1)) {
          await _cursorDelHour(true, hour, minute);
        } else {
          await _cursorDelHour(false, hour, minute);
        }
      } else if (prevMinute1 != minute) {
        if (minute.substring(0, 1) != prevMinute1.substring(0, 1)) {
          await _cursorDelMinute(true, minute);
        } else {
          await _cursorDelMinute(false, minute);
        }
      }
    }
    setState(() {
      prevHour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
          .format(_currentTime);
      prevMinute = DateFormat('mm').format(_currentTime);
    });
  }

  Future _initlizer() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      cursorStartPositionX = MediaQuery.of(context).size.width / 2 -
          MediaQuery.of(context).size.width * characterToDeviceWidthRatio / 2;
      cursorStartPositionY = MediaQuery.of(context).size.height / 2 -
          MediaQuery.of(context).size.height * characterToDeviceHeightRatio / 2;
      xCursor = cursorStartPositionX;
      yCursor = cursorStartPositionY;

      timeFontSize = MediaQuery.of(context).size.width *
          characterToDeviceWidthRatio *
          fontSizeToCharacterWidthRatio;
    });
    await _cursorMove(false);
  }

  Future _cursorDelMinute(bool isEverything, String minute) async {
    final fnlW =
        characterToDeviceWidthRatio * MediaQuery.of(context).size.width;

    await _cursorMove(true);

    await Future.delayed(Duration(milliseconds: tpDelay));
    if (isEverything) {
      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteColor2 = colors[_Element.background];
      });

      await Future.delayed(Duration(milliseconds: tpDelay));

      setState(() {
        xCursor = 1 * fnlW + cursorStartPositionX;
        minuteToShow = minute;
      });

      await Future.delayed(Duration(milliseconds: tpDelay));

      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteColor2 = colors[_Element.text];
      });
    } else {
      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteToShow = minute;
      });
    }
    // await Future.delayed(Duration(milliseconds: tpDelay));

    await _cursorMove(false);
  }

  Future _cursorDelHour(bool isEverything, String hour, String minute) async {
    await _cursorMove(true);

    final fnlW =
        characterToDeviceWidthRatio * MediaQuery.of(context).size.width;
    await Future.delayed(Duration(milliseconds: tpDelay));
    if (isEverything) {
      print(minuteColor2);
      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteColor2 = colors[_Element.background];
      });
      print(minuteColor2);
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 1 * fnlW + cursorStartPositionX;
        minuteColor1 = colors[_Element.background];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 0 * fnlW + cursorStartPositionX;
        colonColor = colors[_Element.background];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = -1 * fnlW + cursorStartPositionX;
        hourColor2 = colors[_Element.background];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = -2 * fnlW + cursorStartPositionX;
        hourToShow = hour;
        minuteToShow = minute;
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = -1 * fnlW + cursorStartPositionX;
        hourColor2 = colors[_Element.text];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 0 * fnlW + cursorStartPositionX;
        colonColor = colors[_Element.text];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 1 * fnlW + cursorStartPositionX;
        minuteColor1 = colors[_Element.text];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteColor2 = colors[_Element.text];
      });
    } else {
      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteColor2 = colors[_Element.background];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 1 * fnlW + cursorStartPositionX;
        minuteColor1 = colors[_Element.background];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 0 * fnlW + cursorStartPositionX;
        colonColor = colors[_Element.background];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = -1 * fnlW + cursorStartPositionX;
        minuteToShow = minute;
        hourToShow = hour;
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 0 * fnlW + cursorStartPositionX;
        colonColor = colors[_Element.text];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 1 * fnlW + cursorStartPositionX;
        minuteColor1 = colors[_Element.text];
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        xCursor = 2 * fnlW + cursorStartPositionX;
        minuteColor2 = colors[_Element.text];
      });
    }
    // await Future.delayed(Duration(milliseconds: tpDelay));
    await _cursorMove(false);
  }

  Future _cursorMove(bool isIn) async {
    final fnlH =
        characterToDeviceHeightRatio * MediaQuery.of(context).size.height;
    final fnlW =
        characterToDeviceWidthRatio * MediaQuery.of(context).size.width;
    if (isIn) {
      setState(() {
        yCursor = -1 * fnlH + cursorStartPositionY;
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        yCursor = 0 * fnlH + cursorStartPositionY;
        xCursor = 3 * fnlW + cursorStartPositionX;
      });
    } else {
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        yCursor = 0 * fnlH + cursorStartPositionY;
        xCursor = 3 * fnlW + cursorStartPositionX;
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        yCursor = -1 * fnlH + cursorStartPositionY;
        xCursor = -2 * fnlW + cursorStartPositionX;
      });
      await Future.delayed(Duration(milliseconds: tpDelay));
      setState(() {
        yCursor = fnlH * -2;
      });
    }
  }

  _txtReturn() {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          hourToShow.substring(0, 1),
          style: GoogleFonts.courierPrime(
            fontSize: timeFontSize,
            textStyle: TextStyle(color: hourColor1),
          ),
        ),
        Text(
          hourToShow.substring(1, 2),
          style: GoogleFonts.courierPrime(
            fontSize: timeFontSize,
            textStyle: TextStyle(color: hourColor2),
          ),
        ),
        Text(
          ":",
          style: GoogleFonts.courierPrime(
            fontSize: timeFontSize,
            textStyle: TextStyle(
              color: colonColor,
            ),
          ),
        ),
        Text(
          minuteToShow.substring(0, 1),
          style: GoogleFonts.courierPrime(
            fontSize: timeFontSize,
            textStyle: TextStyle(
              color: minuteColor1,
            ),
          ),
        ),
        Text(
          minuteToShow.substring(1, 2),
          style: GoogleFonts.courierPrime(
            fontSize: timeFontSize,
            textStyle: TextStyle(
              color: minuteColor2,
            ),
          ),
        )
      ]),
    );
  }

  double timeFontSize = 115;

  String hourToShow;
  String minuteToShow;

  bool isReady = false;
  bool init = true;

  bool is24hour;

//Colors of the characters. Needed to be assigned to each of the charachter, so you can achieve cmd deletion effect.
  Color colonColor = Colors.black;
  Color hourColor1 = Colors.black;
  Color hourColor2 = Colors.black;
  Color minuteColor1 = Colors.black;
  Color minuteColor2 = Colors.black;

  var colors;

//Cursor position. (0,0) is in the middle of the screen.
  var cursorStartPositionX;
  var cursorStartPositionY;
  double xCursor;
  double yCursor;
  double opacityCursor = 1;

//delay between cursor movements
  int tpDelay = 400;

  var prevColors;

//ratio important values
  final characterToDeviceWidthRatio = 0.14217032967032966;
  final characterToDeviceHeightRatio = 0.403125;
  final fontSizeToCharacterWidthRatio = 1.6666666666666667;

  @override
  Widget build(BuildContext context) {
    setState(() {
      colors = Theme.of(context).brightness == Brightness.light
          ? _lightTheme
          : _darkTheme;
      if (prevColors != colors) {
        colonColor = colors[_Element.text];
        hourColor1 = colors[_Element.text];
        hourColor2 = colors[_Element.text];
        minuteColor1 = colors[_Element.text];
        minuteColor2 = colors[_Element.text];
        prevColors = colors;
      }
    });

    return Center(
      child: Scaffold(
        backgroundColor: colors[_Element.background],
        body: isReady
            ? Stack(
                children: <Widget>[
                  Positioned(
                      top: MediaQuery.of(context).size.height / 2 -
                          (characterToDeviceHeightRatio *
                              MediaQuery.of(context).size.height /
                              2),
                      left: MediaQuery.of(context).size.width / 2 -
                          (((hourToShow.toString() + minuteToShow.toString())
                                      .length +
                                  1) *
                              (characterToDeviceWidthRatio *
                                  MediaQuery.of(context).size.width) /
                              2),
                      child: _txtReturn()),
                  Positioned(
                    //Cursor
                    bottom: yCursor,
                    left: xCursor,
                    child: Opacity(
                      opacity: opacityCursor,
                      child: Container(
                        color: colors[_Element.text],
                        width: MediaQuery.of(context).size.width *
                            characterToDeviceWidthRatio,
                        height: MediaQuery.of(context).size.height *
                            characterToDeviceHeightRatio,
                      ),
                    ),
                  )
                ],
              )
            : Center(
                child: Container(
                  child: Text(
                    "Hello, World!",
                    style: GoogleFonts.courierPrime(
                      fontSize: timeFontSize / 3,
                      textStyle: TextStyle(color: hourColor1),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
