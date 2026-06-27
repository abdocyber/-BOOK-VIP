
import 'package:flutter/material.dart';

void safeBack(BuildContext context, String fallbackRoute) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacementNamed(context, fallbackRoute);
  }
}
