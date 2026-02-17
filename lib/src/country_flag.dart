final RegExp _countryCodeRegex = RegExp(r'^[A-Z]{2}$');

const int _regionalIndicatorSymbolLetterA = 0x1F1E6;
const int _asciiUppercaseLetterA = 0x41;

String countryFlagEmoji(String countryCode) {
  final normalized = countryCode.trim().toUpperCase();
  if (!_countryCodeRegex.hasMatch(normalized)) {
    return '🏳';
  }

  final first =
      _regionalIndicatorSymbolLetterA +
      normalized.codeUnitAt(0) -
      _asciiUppercaseLetterA;
  final second =
      _regionalIndicatorSymbolLetterA +
      normalized.codeUnitAt(1) -
      _asciiUppercaseLetterA;
  return String.fromCharCodes(<int>[first, second]);
}
