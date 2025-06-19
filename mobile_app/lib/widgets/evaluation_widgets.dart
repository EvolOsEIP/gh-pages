import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_app/utils/stars.dart';

/// Builds a heart icon based on the [life] remaining.
///
/// If the user has full life (2), a full heart is displayed. If they have one life left (1), a hollow heart
/// is shown. If no lives are left (0), an empty heart is displayed.
Widget buildHeart(int life) {
  double size = 45;

  if (life == 2) {
    return SvgPicture.asset(
      'assets/images/full_heart.svg',
      width: size,
      height: size,
    );
  } else if (life == 1) {
    return SvgPicture.asset(
      'assets/images/half_heart.svg',
      width: size,
      height: size,
    );
  }
  return SvgPicture.asset(
    'assets/images/broken_heart.svg',
    width: size,
    height: size,
  );
}

/// Builds a star rating widget based on the [score].
///
/// The number of stars is determined based on the score provided, where 3 stars are given for scores 80 and above,
/// 2 stars for scores between 60 and 79, and 1 star for scores between 40 and 59.
Widget buildStars(double score) {
  int stars = calculateStars(score);

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(3, (index) {
      return Icon(
        index < stars ? Icons.star : Icons.star_border,
        color: Colors.amber,
      );
    }),
  );
}