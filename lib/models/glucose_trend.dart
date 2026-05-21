/// Glucose trend direction based on rate of change.
enum GlucoseTrend {
  doubleDown('↓↓'),
  down('↓'),
  fortyFiveDown('↘'),
  flat('→'),
  fortyFiveUp('↗'),
  up('↑'),
  doubleUp('↑↑');

  const GlucoseTrend(this.symbol);
  final String symbol;

  static GlucoseTrend fromSlope(double slopeMgDlPer5Min) {
    if (slopeMgDlPer5Min > 3) return GlucoseTrend.doubleUp;
    if (slopeMgDlPer5Min > 1.5) return GlucoseTrend.up;
    if (slopeMgDlPer5Min > 0.5) return GlucoseTrend.fortyFiveUp;
    if (slopeMgDlPer5Min < -3) return GlucoseTrend.doubleDown;
    if (slopeMgDlPer5Min < -1.5) return GlucoseTrend.down;
    if (slopeMgDlPer5Min < -0.5) return GlucoseTrend.fortyFiveDown;
    return GlucoseTrend.flat;
  }
}
