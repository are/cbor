/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;

void main() {
  group('RFC Appendix A Diagnostics encoder tests -> ', () {
    // Common initialisation
    cbor.init();
    final output = cbor.OutputStandard();
    final encoder = cbor.Encoder(output);

    test('0', () {
      output.clear();
      encoder.writeInt(0);
      expect(output.getDataAsList(), [0x00]);
    });

    test('1', () {
      output.clear();
      encoder.writeInt(1);
      expect(output.getDataAsList(), [0x01]);
    });

    test('10', () {
      output.clear();
      encoder.writeInt(10);
      expect(output.getDataAsList(), [0x0a]);
    });

    test('23', () {
      output.clear();
      encoder.writeInt(23);
      expect(output.getDataAsList(), [0x17]);
    });

    test('24', () {
      output.clear();
      encoder.writeInt(24);
      expect(output.getDataAsList(), [0x18, 0x18]);
    });

    test('25', () {
      output.clear();
      encoder.writeInt(25);
      expect(output.getDataAsList(), [0x18, 0x19]);
    });

    test('100', () {
      output.clear();
      encoder.writeInt(100);
      expect(output.getDataAsList(), [0x18, 0x64]);
    });

    test('1000', () {
      output.clear();
      encoder.writeInt(1000);
      expect(output.getDataAsList(), [0x19, 0x03, 0xe8]);
    });

    test('1000000', () {
      output.clear();
      encoder.writeInt(1000000);
      expect(output.getDataAsList(), [0x1a, 0x00, 0x0f, 0x42, 0x40]);
    });

    test('-1', () {
      output.clear();
      encoder.writeInt(-1);
      expect(output.getDataAsList(), [0x20]);
    });

    test('-10', () {
      output.clear();
      encoder.writeInt(-10);
      expect(output.getDataAsList(), [0x29]);
    });

    test('-100', () {
      output.clear();
      encoder.writeInt(-100);
      expect(output.getDataAsList(), [0x38, 0x63]);
    });

    test('-1000', () {
      output.clear();
      encoder.writeInt(-1000);
      expect(output.getDataAsList(), [0x39, 0x03, 0xe7]);
    });

    test('-18446744073709551617', () {
      output.clear();
      final data = typed.Uint8Buffer();
      data.addAll([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      encoder.writeTag(3);
      encoder.writeBytes(data);
      expect(output.getDataAsList(),
          [0xc3, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
    });

    test('0.0', () {
      output.clear();
      encoder.writeHalf(0.0);
      expect(output.getDataAsList(), [0xf9, 0x00, 0x00]);
    });

    test('-0.0', () {
      output.clear();
      encoder.writeHalf(-0.0);
      expect(output.getDataAsList(), [0xf9, 0x80, 0x00]);
    });

    test('1.0', () {
      output.clear();
      encoder.writeHalf(1.0);
      expect(output.getDataAsList(), [0xf9, 0x3c, 0x00]);
    });

    test('1.5', () {
      output.clear();
      encoder.writeHalf(1.5);
      expect(output.getDataAsList(), [0xf9, 0x3e, 0x00]);
    });

    test('65504.0', () {
      output.clear();
      encoder.writeHalf(65504.0);
      expect(output.getDataAsList(), [0xf9, 0x7b, 0xff]);
      output.clear();
      encoder.writeFloat(65504.0);
      expect(output.getDataAsList(), [0xf9, 0x7b, 0xff]);
    });

    test('100000.0', () {
      output.clear();
      encoder.writeSingle(100000.0);
      expect(output.getDataAsList(), [0xfa, 0x47, 0xc3, 0x50, 0x00]);
      output.clear();
      encoder.writeFloat(100000.0);
      expect(output.getDataAsList(), [0xfa, 0x47, 0xc3, 0x50, 0x00]);
    });

    test('3.4028234663852886e+38', () {
      output.clear();
      encoder.writeSingle(3.4028234663852886e+38);
      expect(output.getDataAsList(), [0xfa, 0x7f, 0x7f, 0xff, 0xff]);
      output.clear();
      encoder.writeFloat(3.4028234663852886e+38);
      expect(output.getDataAsList(), [0xfa, 0x7f, 0x7f, 0xff, 0xff]);
    });

    test('1.0e+300', () {
      output.clear();
      encoder.writeDouble(1.0e+300);
      expect(output.getDataAsList(),
          [0xfb, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c]);
      output.clear();
      encoder.writeFloat(1.0e+300);
      expect(output.getDataAsList(),
          [0xfb, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c]);
    });

    test('5.960464477539063e-8', () {
      output.clear();
      encoder.writeHalf(5.960464477539063e-8);
      expect(output.getDataAsList(), [0xf9, 0x00, 0x01]);
    });

    test('0.00006103515625', () {
      output.clear();
      encoder.writeHalf(0.00006103515625);
      expect(output.getDataAsList(), [0xf9, 0x04, 0x00]);
    });

    test('-4.0', () {
      output.clear();
      encoder.writeHalf(-4.0);
      expect(output.getDataAsList(), [0xf9, 0xc4, 0x00]);
    });

    test('-4.1', () {
      output.clear();
      encoder.writeDouble(-4.1);
      expect(output.getDataAsList(),
          [0xfb, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66]);
      output.clear();
      encoder.writeHalf(-4.1);
      expect(output.getDataAsList(), [0xf9, 0xc4, 0x19]);
    });

    test('Infinity Half', () {
      output.clear();
      encoder.writeHalf(double.infinity);
      expect(output.getDataAsList(), [0xf9, 0x7c, 0x00]);
    });

    test('Nan Half', () {
      output.clear();
      encoder.writeHalf(double.nan);
      expect(output.getDataAsList(), [0xf9, 0x7e, 0x00]);
    });

    test('-Infinity Half', () {
      output.clear();
      encoder.writeHalf(-double.infinity);
      expect(output.getDataAsList(), [0xf9, 0xfc, 0x00]);
    });

    test('Infinity Single', () {
      output.clear();
      encoder.writeSingle(double.infinity);
      expect(output.getDataAsList(), [0xfa, 0x7f, 0x80, 0x00, 0x00]);
    });

    test('Nan Single', () {
      output.clear();
      encoder.writeSingle(double.nan);
      expect(output.getDataAsList(), [0xfa, 0x7f, 0xc0, 0x00, 0x00]);
    });

    test('-Infinity Single', () {
      output.clear();
      encoder.writeSingle(-double.infinity);
      expect(output.getDataAsList(), [0xfa, 0xff, 0x80, 0x00, 0x00]);
    });

    test('Infinity Double', () {
      output.clear();
      encoder.writeDouble(double.infinity);
      expect(output.getDataAsList(),
          [0xfb, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
    });

    test('Nan Double', () {
      output.clear();
      encoder.writeDouble(double.nan);
      expect(output.getDataAsList(),
          [0xfb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
    });

    test('-Infinity Double', () {
      output.clear();
      encoder.writeDouble(-double.infinity);
      expect(output.getDataAsList(),
          [0xfb, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
    });

    test('False', () {
      output.clear();
      encoder.writeBool(false);
      expect(output.getDataAsList(), [0xf4]);
    });

    test('True', () {
      output.clear();
      encoder.writeBool(true);
      expect(output.getDataAsList(), [0xf5]);
    });

    test('Null', () {
      output.clear();
      encoder.writeNull();
      expect(output.getDataAsList(), [0xf6]);
    });

    test('Simple 16', () {
      output.clear();
      encoder.writeSimple(16);
      expect(output.getDataAsList(), [0xf0]);
    });

    test('Simple 24', () {
      output.clear();
      encoder.writeSimple(24);
      expect(output.getDataAsList(), [0xf8, 0x18]);
    });

    test('Simple 255', () {
      output.clear();
      encoder.writeSimple(255);
      expect(output.getDataAsList(), [0xf8, 0xff]);
    });

    test('Simple 1000', () {
      output.clear();
      encoder.writeSimple(1000);
      expect(output.getDataAsList(), [0x19, 0x03, 0xe8]);
    });

    test('Simple -1000', () {
      output.clear();
      encoder.writeSimple(-1000);
      expect(output.getDataAsList(), [0x39, 0x03, 0xe7]);
    });

    test('Date/Time', () {
      output.clear();
      encoder.writeDateTime('2013-03-21T20:04:00Z');
      expect(output.getDataAsList(), [
        0xc0,
        0x74,
        0x32,
        0x30,
        0x31,
        0x33,
        0x2d,
        0x30,
        0x33,
        0x2d,
        0x32,
        0x31,
        0x54,
        0x32,
        0x30,
        0x3a,
        0x30,
        0x34,
        0x3a,
        0x30,
        0x30,
        0x5a
      ]);
    });

    test('Epoch 1363896240', () {
      output.clear();
      encoder.writeEpoch(1363896240);
      expect(output.getDataAsList(), [0xc1, 0x1a, 0x51, 0x4b, 0x67, 0xb0]);
    });

    test('Epoch 1363896240.5', () {
      output.clear();
      encoder.writeEpoch(1363896240.5, cbor.encodeFloatAs.double);
      expect(output.getDataAsList(),
          [0xc1, 0xfb, 0x41, 0xd4, 0x52, 0xd9, 0xec, 0x20, 0x00, 0x00]);
    });

    test('Base16', () {
      output.clear();
      final buff = typed.Uint8Buffer();
      buff.addAll([01, 02, 03, 04]);
      encoder.writeBase16(buff);
      expect(output.getDataAsList(), [0xd7, 0x44, 0x01, 0x02, 0x03, 0x04]);
    });

    test('Base64', () {
      output.clear();
      final buff = typed.Uint8Buffer();
      buff.addAll([0x01, 0x02, 0x03, 0x04]);
      encoder.writeBase64(buff);
      expect(output.getDataAsList(), [0xd6, 0x44, 0x01, 0x02, 0x03, 0x04]);
    });

    test('CBOR Data Item', () {
      output.clear();
      final buff = typed.Uint8Buffer();
      buff.addAll([0x64, 0x49, 0x45, 0x54, 0x46]);
      encoder.writeCborDi(buff);
      expect(output.getDataAsList(),
          [0xd8, 0x18, 0x45, 0x64, 0x49, 0x45, 0x54, 0x46]);
    });

    test('URI', () {
      output.clear();
      encoder.writeURI('http://www.example.com');
      expect(output.getDataAsList(), [
        0xd8,
        0x20,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ]);
    });

    test('Regex', () {
      output.clear();
      encoder.writeRegEx('^[123]/g');
      expect(output.getDataAsList(), [
        0xd8,
        0x23,
        0x68,
        0x5e,
        0x5b,
        0x31,
        0x32,
        0x33,
        0x5d,
        0x2f,
        0x67,
      ]);
    });

    test('Mime Message', () {
      output.clear();
      const mimeMessage = 'MIME-Version: 1.0'
          'X-Mailer: MailBee.NET 8.0.4.428'
          'Subject: This is the subject of a sample message'
          'To: user@example.com'
          'Content-Type: multipart/alternative'
          'boundary="XXXXboundary text"'
          'This is the body text of a sample message.'
          '--XXXXboundary text--';
      final checkList = <int>[];
      checkList.addAll([0xd8, 0x24, 0x78, 0xf2]);
      checkList.addAll(mimeMessage.codeUnits);
      encoder.writeMimeMessage(mimeMessage);
      expect(output.getDataAsList(), checkList);
    });

    test('Empty single quote string', () {
      output.clear();
      final buff = typed.Uint8Buffer();
      encoder.writeBytes(buff);
      expect(output.getDataAsList(), [0x40]);
    });

    test('single quote string', () {
      output.clear();
      final buff = typed.Uint8Buffer();
      buff.addAll([0x01, 0x02, 0x03, 0x04]);
      encoder.writeBytes(buff);
      expect(output.getDataAsList(), [0x44, 0x01, 0x02, 0x03, 0x04]);
    });

    test('Empty double quote string', () {
      output.clear();
      encoder.writeString('');
      expect(output.getDataAsList(), [0x60]);
    });

    test('"a"', () {
      output.clear();
      encoder.writeString('a');
      expect(output.getDataAsList(), [0x61, 0x61]);
    });

    test('"IETF"', () {
      output.clear();
      encoder.writeString('IETF');
      expect(output.getDataAsList(), [0x64, 0x49, 0x45, 0x54, 0x46]);
    });

    test('\"\\', () {
      output.clear();
      encoder.writeString('\"\\');
      expect(output.getDataAsList(), [0x62, 0x22, 0x5c]);
    });

    test('\u00fc', () {
      output.clear();
      encoder.writeString('\u00fc');
      expect(output.getDataAsList(), [0x62, 0xc3, 0xbc]);
    });

    test('\u6c34', () {
      output.clear();
      encoder.writeString('\u6c34');
      expect(output.getDataAsList(), [0x63, 0xe6, 0xb0, 0xb4]);
    });

    test('\ud800\udd51', () {
      output.clear();
      encoder.writeString('\ud800\udd51');
      expect(output.getDataAsList(), [0x64, 0xf0, 0x90, 0x85, 0x91]);
    });

    test('Array empty', () {
      output.clear();
      final res = encoder.writeArray([]);
      expect(res, isTrue);
      expect(output.getDataAsList(), [0x80]);
    });

    test('Array 1,2,3', () {
      output.clear();
      final res = encoder.writeArray([1, 2, 3]);
      expect(res, isTrue);
      expect(output.getDataAsList(), [0x83, 0x01, 0x02, 0x03]);
    });

    test('Array 1,[2,3],[4,5]', () {
      output.clear();
      final res = encoder.writeArray([
        1,
        [2, 3],
        [4, 5]
      ]);
      expect(res, isTrue);
      expect(output.getDataAsList(),
          [0x83, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05]);
    });

    test('Array 1..25', () {
      output.clear();
      final res = encoder.writeArray([
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25
      ]);
      expect(res, isTrue);
      expect(output.getDataAsList(), [
        0x98,
        0x19,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0a,
        0x0b,
        0x0c,
        0x0d,
        0x0e,
        0x0f,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19
      ]);
    });

    test('Map empty', () {
      output.clear();
      final res = encoder.writeMap({});
      expect(res, isTrue);
      expect(output.getDataAsList(), [0xa0]);
    });

    test('Map {1:2,3:4}', () {
      output.clear();
      final res = encoder.writeMap({1: 2, 3: 4});
      expect(res, isTrue);
      expect(output.getDataAsList(), [0xa2, 0x01, 0x02, 0x03, 0x04]);
    });

    test('Map {a:1,b:[2,3]}', () {
      output.clear();
      final res = encoder.writeMap({
        'a': 1,
        'b': [2, 3]
      });
      expect(res, isTrue);
      expect(output.getDataAsList(),
          [0xa2, 0x61, 0x61, 0x01, 0x061, 0x62, 0x82, 0x02, 0x03]);
    });

    test('Map [a,{b:c}]', () {
      output.clear();
      final res = encoder.writeArray([
        'a',
        {'b': 'c'}
      ]);
      expect(res, isTrue);
      expect(output.getDataAsList(),
          [0x82, 0x61, 0x61, 0xa1, 0x61, 0x62, 0x61, 0x63]);
    });

    test('Map {"a": "A", "b": "B", "c": "C", "d": "D", "e": "E"}', () {
      output.clear();
      final res =
          encoder.writeMap({'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D', 'e': 'E'});
      expect(res, isTrue);
      expect(output.getDataAsList(), [
        0xa5,
        0x61,
        0x61,
        0x61,
        0x41,
        0x61,
        0x62,
        0x61,
        0x42,
        0x61,
        0x63,
        0x61,
        0x43,
        0x61,
        0x64,
        0x61,
        0x44,
        0x61,
        0x65,
        0x61,
        0x45
      ]);
    });

    test('Indefinite Bytestring 0102030405', () {
      output.clear();
      final data = typed.Uint8Buffer();
      data.addAll([0x01, 0x02]);
      encoder.writeBuff(data, true);
      final data1 = typed.Uint8Buffer();
      data1.addAll([0x03, 0x04, 0x05]);
      encoder.writeBuff(data1);
      encoder.writeBreak();
      expect(output.getDataAsList(),
          [0x5f, 0x42, 0x01, 0x02, 0x43, 0x03, 0x04, 0x05, 0xff]);
    });

    test('Indefinite String strea,ming', () {
      output.clear();
      encoder.writeString('strea', true);
      encoder.writeString('ming');
      encoder.writeBreak();
      expect(output.getDataAsList(), [
        0x7f,
        0x65,
        0x73,
        0x74,
        0x72,
        0x65,
        0x61,
        0x64,
        0x6d,
        0x69,
        0x6e,
        0x67,
        0xff
      ]);
    });

    test('Indefinite Array empty', () {
      output.clear();
      final res = encoder.writeArray([], true);
      encoder.writeBreak();
      expect(res, isTrue);
      expect(output.getDataAsList(), [0x9f, 0xff]);
    });

    test('Indefinite Array [_1, [2,3], [_4,5]', () {
      output.clear();
      final res1 = encoder.writeArray([
        1,
      ], true);
      expect(res1, isTrue);
      final res2 = encoder.writeArray([2, 3]);
      expect(res2, isTrue);
      final res3 = encoder.writeArray([4, 5], true);
      expect(res3, isTrue);
      encoder.writeBreak();
      encoder.writeBreak();
      expect(output.getDataAsList(),
          [0x9f, 0x01, 0x82, 0x02, 0x03, 0x9f, 0x04, 0x05, 0xff, 0xff]);
    });

    test('Indefinite Array [_1, [2,3], [4,5]', () {
      output.clear();
      final res1 = encoder.writeArray([1], true);
      expect(res1, isTrue);
      final res2 = encoder.writeArray([2, 3], false);
      expect(res2, isTrue);
      final res3 = encoder.writeArray([4, 5], false);
      expect(res3, isTrue);
      encoder.writeBreak();
      expect(output.getDataAsList(),
          [0x9f, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05, 0xff]);
    });

    test('Indefinite Array [1, [_2,3], [4,5]', () {
      output.clear();
      final res1 = encoder.writeArray([1], false, 3);
      expect(res1, isTrue);
      final res2 = encoder.writeArray([2, 3], true);
      expect(res2, isTrue);
      encoder.writeBreak();
      final res3 = encoder.writeArray([4, 5], false);
      expect(res3, isTrue);
      expect(output.getDataAsList(),
          [0x83, 0x01, 0x9f, 0x02, 0x03, 0xff, 0x82, 0x04, 0x05]);
    });

    test('Indefinite Array [_1..25]', () {
      output.clear();
      final res = encoder.writeArray([
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25
      ], true);
      expect(res, isTrue);
      encoder.writeBreak();
      expect(output.getDataAsList(), [
        0x9f,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0a,
        0x0b,
        0x0c,
        0x0d,
        0x0e,
        0x0f,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19,
        0xff
      ]);
    });

    test('Indefinite Map {_a:1, b:[_2,3]}', () {
      output.clear();
      output.pause();
      final res1 = encoder.writeArray([2, 3], true);
      expect(res1, isTrue);
      final val = output.getDataAsList();
      output.restart();
      final res2 = encoder.writeMap({'a': 1, 'b': val}, true);
      expect(res2, isTrue);
      encoder.writeBreak();
      encoder.writeBreak();
      expect(output.getDataAsList(),
          [0xbf, 0x61, 0x61, 0x01, 0x61, 0x62, 0x9f, 0x02, 0x03, 0xff, 0xff]);
    });

    test('Indefinite Array [a, {_"b":"c"}', () {
      output.clear();
      output.pause();
      final res1 = encoder.writeMap({'b': 'c'}, true);
      expect(res1, isTrue);
      final val = output.getData();
      output.restart();
      final res2 = encoder.writeArray(['a'], false, 2);
      expect(res2, isTrue);
      encoder.writeRawBuffer(val);
      encoder.writeBreak();
      expect(output.getDataAsList(),
          [0x82, 0x61, 0x61, 0xbf, 0x61, 0x62, 0x61, 0x63, 0xff]);
    });

    test('Indefinite Map {_ "Fun": true, "Amt": -2}', () {
      output.clear();
      final res1 = encoder.writeMap({'Fun': true, 'Amt': -2}, true);
      expect(res1, isTrue);
      encoder.writeBreak();
      expect(output.getDataAsList(), [
        0xbf,
        0x63,
        0x46,
        0x75,
        0x6e,
        0xf5,
        0x63,
        0x41,
        0x6d,
        0x74,
        0x21,
        0xff
      ]);
    });
  });
}
