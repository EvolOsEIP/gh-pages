int calculateStars(double finalScore) {
  if (finalScore >= 80.0) return 3;
  if (finalScore >= 60.0) return 2;
  if (finalScore >= 40.0) return 1;
  return 0;
}