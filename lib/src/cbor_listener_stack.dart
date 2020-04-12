/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// What we are waiting for next, if anything.
enum whatsNext {
  aDateTimeString,
  aDateTimeEpoch,
  aDecimalFraction,
  aBigFloat,
  unassigned,
  aPositiveBignum,
  aNegativeBignum,
  aMultipleB64Url,
  aMultipleB64,
  aMultipleB16,
  encodedCBOR,
  aStringUri,
  aStringB64Url,
  aStringB64,
  aRegExp,
  aMIMEMessage,
  aSelfDescribeCBOR,
  nothing
}

/// The stack based listener class, produces a stack of DartItems
/// from the decoder output.
class ListenerStack extends Listener {
  /// Used to indicate what the
  /// next decoded item should be.
  whatsNext _next = whatsNext.nothing;

  /// Indefinite stack.
  /// A list of indefinite items, most recent at the end.
  /// Can only be string, bytes, list or map.
  final List<String> _indefiniteStack = <String>[];

  /// Indefinite bytes buffer assembler.
  final typed.Uint8Buffer _byteAssembly = typed.Uint8Buffer();

  /// Indefinite item stack, stack to use when
  /// in an indefinite sequence.
  final ItemStack _indefiniteItemStack = ItemStack();

  /// Indefinite String buffer assembler.
  String _stringAssembly;

  /// Incremented on every indefinite start, decremented on stop
  /// used to indicate and indefinite sequence in progress.
  int _indefiniteStartCount = 0;

  @override
  void onInteger(int value) {
    // Do not add nulls
    if (value == null) {
      return;
    }
    final item = DartItem();
    item.data = value;
    item.type = dartTypes.dtInt;
    item.complete = true;
    if (_next == whatsNext.aDateTimeEpoch) {
      item.hint = dataHints.dateTimeEpoch;
      _next = whatsNext.nothing;
    }
    _append(item);
  }

  void onBigInteger(BigInt value) {
    // Do not add nulls
    if (value == null) {
      return;
    }
    final item = DartItem();
    item.data = value;
    item.type = dartTypes.dtBigInt;
    item.complete = true;
    if (_next == whatsNext.aDateTimeEpoch) {
      item.hint = dataHints.dateTimeEpoch;
      _next = whatsNext.nothing;
    }
    _append(item);
  }

  @override
  void onBytes(typed.Uint8Buffer data, int size) {
    // Check if we are expecting something, ie whats next
    switch (_next) {
      case whatsNext.aPositiveBignum:
        // Convert to a positive integer and append
        final value = bignumToBigInt(data, '+');
        onBigInteger(value);
        break;
      case whatsNext.aNegativeBignum:
        var value = bignumToBigInt(data, '-');
        value = BigInt.from(-1) + value;
        onBigInteger(value.abs());
        break;
      case whatsNext.aMultipleB64Url:
        if (data != null) {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.base64Url;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.aMultipleB64:
        if (data != null) {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.base64;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.aMultipleB16:
        if (data != null) {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.base16;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.encodedCBOR:
        if (data != null) {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.encodedCBOR;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.aSelfDescribeCBOR:
        if (data != null) {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.selfDescCBOR;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.unassigned:
        if (data != null) {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.nothing:
      default:
        if (data == null) {
          return;
        }
        if (_waitingIndefBytes()) {
          _byteAssembly.addAll(data);
        } else {
          final item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.complete = true;
          _append(item);
        }
    }
    _next = whatsNext.nothing;
  }

  @override
  void onString(String str) {
    if (str == null) {
      return;
    }
    if (_waitingIndefString()) {
      _stringAssembly += str;
    } else {
      final item = DartItem();
      item.data = str;
      item.type = dartTypes.dtString;
      switch (_next) {
        case whatsNext.aDateTimeString:
          item.hint = dataHints.dateTimeString;
          break;
        case whatsNext.aStringUri:
          item.hint = dataHints.uri;
          break;
        case whatsNext.aStringB64Url:
          item.hint = dataHints.base64Url;
          break;
        case whatsNext.aStringB64:
          item.hint = dataHints.base64;
          break;
        case whatsNext.aRegExp:
          item.hint = dataHints.regex;
          break;
        case whatsNext.aMIMEMessage:
          item.hint = dataHints.mime;
          break;
        default:
          break;
      }
      _next = whatsNext.nothing;
      item.complete = true;
      _append(item);
    }
  }

  @override
  void onArray(int size) {
    final item = DartItem();
    item.type = dartTypes.dtList;
    item.data = <dynamic>[];
    item.targetSize = size;
    if (size == 0) {
      item.complete = true;
    }
    _append(item);
  }

  @override
  void onMap(int size) {
    final item = DartItem();
    item.type = dartTypes.dtMap;
    item.data = <dynamic, dynamic>{};
    item.targetSize = size;
    if (size == 0) {
      item.complete = true;
    }
    _append(item);
  }

  @override
  void onTag(int tag) {
    // Switch on the tag type
    switch (tag) {
      case tagDateTimeStandard: // Date time string
        _next = whatsNext.aDateTimeString;
        break;
      case tagDateTimeEpoch: // Date/Time epoch
        _next = whatsNext.aDateTimeEpoch;
        break;
      case tagPositiveBignum: // Positive bignum
        _next = whatsNext.aPositiveBignum;
        break;
      case tagNegativeBignum: // Negative bignum
        _next = whatsNext.aNegativeBignum;
        break;
      case tagDecimalFraction: // Decimal fraction
        _next = whatsNext.aDecimalFraction;
        break;
      case tagBigFloat: // Bigfloat
        _next = whatsNext.aBigFloat;
        break;
      case tagExpectedBase64Url: // B64 URL
        _next = whatsNext.aMultipleB64Url;
        break;
      case tagExpectedBase64: // B64
        _next = whatsNext.aMultipleB64;
        break;
      case tagExpectedBase16: // B16
        _next = whatsNext.aMultipleB16;
        break;
      case tagEncodedCborDataItem: // Encoded CBOR item
        _next = whatsNext.encodedCBOR;
        break;
      case tagUri: // URI
        _next = whatsNext.aStringUri;
        break;
      case tagBase64Url: // String B64 URL
        _next = whatsNext.aStringB64Url;
        break;
      case tagBase64: // String B64
        _next = whatsNext.aStringB64;
        break;
      case tagRegularExpression: // Regular Expression
        _next = whatsNext.aRegExp;
        break;
      case tagMimeMessage: // MIME message
        _next = whatsNext.aMIMEMessage;
        break;
      case tagSelfDescribedCbor: // Self describe CBOR sequence
        _next = whatsNext.aSelfDescribeCBOR;
        break;
      default: // Unassigned values
        _next = whatsNext.unassigned;
    }
  }

  @override
  void onSpecial(int code) {
    if (code == null) {
      return;
    }
    final item = DartItem();
    item.data = code;
    item.type = dartTypes.dtInt;
    item.complete = true;
    _append(item);
  }

  @override
  void onSpecialFloat(double value) {
    // Do not add nulls
    if (value == null) {
      return;
    }
    final item = DartItem();
    item.data = value;
    item.type = dartTypes.dtDouble;
    item.complete = true;
    _append(item);
  }

  @override
  void onBool(bool state) {
    // Do not add nulls
    if (state == null) {
      return;
    }
    final item = DartItem();
    item.data = state;
    item.type = dartTypes.dtBool;
    item.complete = true;
    _append(item);
  }

  @override
  void onNull() {
    final item = DartItem();
    item.type = dartTypes.dtNull;
    item.complete = true;
    _append(item);
  }

  @override
  void onUndefined() {
    final item = DartItem();
    item.type = dartTypes.dtUndefined;
    item.complete = true;
    _append(item);
  }

  @override
  void onError(String error) {
    if (error == null) {
      return;
    }
    final item = DartItem();
    item.data = error;
    item.type = dartTypes.dtString;
    item.hint = dataHints.error;
    item.complete = true;
    _append(item);
  }

  @override
  void onExtraInteger(int value, int sign) {
    // Sign adjustment is done by the decoder so
    // we can ignore it here
    onInteger(value);
  }

  @override
  void onExtraTag(int tag) {
    // Not yet implemented
  }

  @override
  void onIndefinite(String text) {
    // Process depending on indefinite type.
    switch (text) {
      case indefBytes:
        _indefiniteStartCount++;
        _indefiniteStack.add(text);
        _byteAssembly.clear();
        break;
      case indefString:
        _indefiniteStartCount++;
        _indefiniteStack.add(text);
        _stringAssembly = '';
        break;
      case indefMap:
        _indefiniteStartCount++;
        _indefiniteStack.add(text);
        onMap(indefiniteMaxSize);
        break;
      case indefArray:
        _indefiniteStartCount++;
        _indefiniteStack.add(text);
        onArray(indefiniteMaxSize);
        break;
      case indefStop:
        // Get the top of the indefinite stack and switch on it.
        if (_indefiniteStack.isEmpty) {
          onError('Unbalanced indefinite break');
          break;
        }
        final top = _indefiniteStack.removeLast();
        switch (top) {
          case indefBytes:
            onBytes(_byteAssembly, _byteAssembly.length);
            break;
          case indefString:
            onString(_stringAssembly);
            break;
          case indefMap:
          case indefArray:
            {
              // Add an indefinite iterable stop item
              final item = DartItem();
              item.type = dartTypes.dtIterableIndefiniteStop;
              item.complete = true;
              _append(item);
            }
            break;
          default:
            onError('Unknown indefinite type on stop');
        }
        _indefiniteStartCount--;
        break;
      default:
        onError('Unknown indefinite type on start');
    }
    // If the indefinite sequence has stopped process it
    if (_indefiniteStartCount == 0) {
      _buildIndefiniteSequence();
    }
  }

  /// Main stack append method.
  void _append(DartItem item) => _indefiniteStartCount == 0
      ? itemStack.push(item)
      : _indefiniteItemStack.push(item);

  /// Helper functions.

  /// Waiting for indefinite bytes.
  bool _waitingIndefBytes() {
    if (_indefiniteStack.isNotEmpty) {
      if (_indefiniteStack.last == indefBytes) {
        return true;
      }
    }
    return false;
  }

  /// Waiting for indefinite string.
  bool _waitingIndefString() {
    if (_indefiniteStack.isNotEmpty) {
      if (_indefiniteStack.last == indefString) {
        return true;
      }
    }
    return false;
  }

  /// Build an indefinite sequence on to the item stack
  void _buildIndefiniteSequence() {
    if (_indefiniteItemStack.peek() == null) {
      return;
    }

    // Walk the stack
    var item;
    while (!_indefiniteItemStack.isEmpty()) {
      item = _indefiniteItemStack.popBottom();

      // Iterable, only recurse if the item is not complete
      if (item.isIterable() && !item.complete) {
        item = _processIndefiniteIterable(item, _indefiniteItemStack);
      }

      // We should now have a complete item
      if (item.complete) {
        itemStack.push(item);
      } else {
        CborException(
            'Listener Stack Indefinite Stack build - Error - attempt to stack incomplete item : $item');
      }

      _indefiniteItemStack.clear();
    }
  }

  /// Process an iterable, list or map
  DartItem _processIndefiniteIterable(DartItem item, ItemStack items) {
    /// List
    if (item.type == dartTypes.dtList) {
      item.data = <dynamic>[];
      for (var i = 0; i < item.targetSize; i++) {
        var iItem = items.popBottom();
        // Check for an indefinite stop
        if (iItem.type == dartTypes.dtIterableIndefiniteStop) {
          break;
        }
        if (iItem.complete) {
          item.data.add(iItem.data);
        } else if (iItem.isIterable()) {
          item.data.add(_processIndefiniteIterable(iItem, items).data);
        } else {
          throw CborException(
              'Listener Stack _processIndefiniteIterable - List item is not iterable or complete ${iItem}');
        }
      }
      item.complete = true;
      return item;
    } else if (item.type == dartTypes.dtMap) {
      item.data = <dynamic, dynamic>{};
      dynamic key;
      dynamic value;
      for (var i = 0; i < item.targetSize; i++) {
        var iItem = items.popBottom();
        if (iItem.type == dartTypes.dtIterableIndefiniteStop) {
          break;
        }
        if (iItem.complete) {
          // Keys cannot be iterable
          key = iItem.data;
        } else {
          throw CborException(
              'Listener Stack _processIndefiniteIterable - item is incomplete map key ${iItem}');
        }
        iItem = items.popBottom();
        if (iItem.complete) {
          value = iItem.data;
        } else if (iItem.isIterable()) {
          value = _processIndefiniteIterable(iItem, items).data;
        } else {
          throw CborException(
              'Listener Stack _processIndefiniteIterable - item is incomplete map key ${iItem}');
        }
        item.data[key] = value;
      }
      item.complete = true;
      return item;
    } else {
      throw CborException(
          'Listener Stack _processIndefiniteIterable - item is iterable but not list or map ${item}');
    }
  }
}
