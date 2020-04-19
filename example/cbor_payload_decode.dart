/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart' as cbor;
import 'package:typed_data/typed_data.dart';

/// A payload based decode.
int main() {
  // Get our cbor instance, always do this,it correctly
  // initialises the decoder.
  final inst = cbor.Cbor();

  // Assume we have received a CBOR encoded byte buffer from the network.
  // The byte sequence below gives :-
  // {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D', 'e': 'E'}
  final payload = <int>[
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
  ];

  final payloadBuffer = Uint8Buffer();
  payloadBuffer.addAll(payload);

  // Decode from the buffer, you can also decode from the
  // int list if you prefer.
  inst.decodeFromBuffer(payloadBuffer);

  // Pretty print, note that these methods use [GetDecodedData] and will
  // thus build the payload buffer.
  // If you do not want to pretty print or use Json just get the list of
  // decoded data directly by calling [GetDecodedData()]
  print(inst.decodedPrettyPrint());

  // JSON, maps can only have string keys to decode to JSON
  print(inst.decodedToJSON());

  return 0;
}
