import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/models/growth_calculator.dart';
import 'package:makeme/utils/enums.dart';

void main() {
  group('GrowthCalculator total', () {
    test('30 minutes at moderate is one growth point', () {
      expect(
        GrowthCalculator.total(
          durationMinutes: 30,
          intensity: Intensity.moderate,
        ),
        1.0,
      );
    });

    test('minutes scale the total', () {
      expect(
        GrowthCalculator.total(
          durationMinutes: 60,
          intensity: Intensity.moderate,
        ),
        2.0,
      );
    });

    test('intensity scales the total', () {
      double total(Intensity i) =>
          GrowthCalculator.total(durationMinutes: 30, intensity: i);

      expect(total(Intensity.light), 0.5);
      expect(total(Intensity.moderate), 1.0);
      expect(total(Intensity.heavy), 1.5);
    });

    test('is rounded to two decimals', () {
      // 20 / 30 = 0.6666...
      expect(
        GrowthCalculator.total(
          durationMinutes: 20,
          intensity: Intensity.moderate,
        ),
        0.67,
      );
    });
  });

  group('GrowthCalculator perPart', () {
    test('splits the total evenly over the selected muscles', () {
      final split = GrowthCalculator.perPart(
        totalGrowth: 2.0,
        bodyParts: [BodyPartName.pects, BodyPartName.lats],
      );

      expect(split, {BodyPartName.pects: 1.0, BodyPartName.lats: 1.0});
    });

    test('each share is rounded to two decimals', () {
      final split = GrowthCalculator.perPart(
        totalGrowth: 1.0,
        bodyParts: [BodyPartName.quads, BodyPartName.glutes, BodyPartName.calves],
      );

      expect(split.values, everyElement(0.33));
    });

    test('no muscles means no growth', () {
      expect(GrowthCalculator.perPart(totalGrowth: 2.0, bodyParts: []), isEmpty);
    });
  });

  group('GrowthCalculator targetFor', () {
    test('grows with the weekly goal', () {
      expect(GrowthCalculator.targetFor(1), 2.0);
      expect(GrowthCalculator.targetFor(3), 6.0);
      expect(GrowthCalculator.targetFor(7), 14.0);
    });

    test('a goal outside 1 to 7 is clamped', () {
      expect(GrowthCalculator.targetFor(0), GrowthCalculator.targetFor(1));
      expect(GrowthCalculator.targetFor(9), GrowthCalculator.targetFor(7));
    });
  });
}
