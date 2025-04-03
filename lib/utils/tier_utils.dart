import 'package:flutter/material.dart';

class TierConverts
{
  static Color TierColor (String tier)
  {
    switch (tier)
    {
      case "Trial":
        return Colors.black;

      case "Starter":
        return Colors.grey[200]!;

      case "Plus":
        return Colors.blueAccent;

      case "Pro":
        return Colors.red[400]!;

      case "Premium":
        return Colors.yellow[800]!;

      case "Enterprise":
        return Colors.amber;
      default:
        return Colors.pink;
    }
  }

  static int TierId(String tier)
  {
    switch (tier)
    {
      case "Trial":
        return 0;

      case "Starter":
        return 1;

      case "Plus":
        return 2;

      case "Pro":
        return 3;

      case "Premium":
        return 4;

      case "Enterprise":
        return 5;
      default:
        return -1;
    }
  }
}