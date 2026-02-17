import 'package:flutter_test/flutter_test.dart';
import 'package:nordacess/src/country_flag.dart';

void main() {
  test('countryFlagEmoji returns flag emoji for uppercase country code', () {
    expect(countryFlagEmoji('JP'), equals('🇯🇵'));
    expect(countryFlagEmoji('US'), equals('🇺🇸'));
  });

  test('countryFlagEmoji normalizes lowercase country code', () {
    expect(countryFlagEmoji('jp'), equals('🇯🇵'));
  });

  test('countryFlagEmoji trims whitespace around code', () {
    expect(countryFlagEmoji('  us  '), equals('🇺🇸'));
  });

  test('countryFlagEmoji returns white flag for invalid code', () {
    expect(countryFlagEmoji(''), equals('🏳'));
    expect(countryFlagEmoji('J'), equals('🏳'));
    expect(countryFlagEmoji('JPN'), equals('🏳'));
    expect(countryFlagEmoji('1P'), equals('🏳'));
  });
}
