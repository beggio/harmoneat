import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/features/chord/application/soundfont_chord_sound_engine.dart';
import 'package:soundfont_kit/soundfont_kit.dart';

const _drumKit = Preset(bank: 128, program: 0, name: 'Standard');
const _piano = Preset(bank: 0, program: 0, name: 'Grand Piano');
const _mellowPiano = Preset(bank: 8, program: 0, name: 'Mellow Grand Piano');
const _ukulele = Preset(bank: 8, program: 24, name: 'Ukulele');
const _guitar = Preset(bank: 0, program: 24, name: 'Nylon String Guitar');
const _electronicKit = Preset(bank: 128, program: 24, name: 'Electronic');
const _choir = Preset(bank: 0, program: 52, name: 'Choir Aahs');

void main() {
  test('picks the bank-0 preset even when a same-program drum kit comes first '
      '— the real bug this fixes: a drum kit shares program 0 with piano', () {
    final presets = [_drumKit, _piano, _mellowPiano];
    expect(selectPreset(presets, 0), same(_piano));
  });

  test('ignores a same-program variant bank entry that sorts earlier', () {
    final presets = [_ukulele, _guitar, _electronicKit];
    expect(selectPreset(presets, 24), same(_guitar));
  });

  test('matches a program whose only entry is already bank 0', () {
    final presets = [_choir];
    expect(selectPreset(presets, 52), same(_choir));
  });

  test('falls back to the first preset if the program has no bank-0 entry', () {
    final presets = [_mellowPiano]; // bank 8 only, no bank-0 piano present
    expect(selectPreset(presets, 0), same(_mellowPiano));
  });

  test('returns null for an empty preset list', () {
    expect(selectPreset(const [], 0), isNull);
  });
}
