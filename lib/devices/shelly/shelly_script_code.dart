import 'dart:convert' show utf8;
import 'dart:math';

const codeChunkMaxSize = 700;

class ShellyScriptCode {
  String originalCode = '';
  String modifiedCode = '';

  void setCode(String newCode) {
    originalCode = newCode;
    modifiedCode = '';
  }

  List<String> checkErrors() {
    //Todo: add checking errors
    return [];
  }

  void modify() {
    modifiedCode = '';

    for (int i=0; i<originalCode.length; i++) {
      if (originalCode[i] == '"') {
        modifiedCode += "'";
      }
      else if (originalCode[i] == '\n') {
       // TODO: skip temporarily newlines
      }
      else if (originalCode[i] == '/') {

        if ((i+1 < originalCode.length) && (originalCode[i+1] == '/')) {
          if ((i>0) && (originalCode[i-1] == ':')) {
            // text part of the internet address
            // TODO: this is ugly hack and should be done better
            modifiedCode += '//';
            i += 1;
          }
          else {
            // skip comment starting //
            int indexOfNewLine = originalCode.indexOf('\n', i + 2);
            i = (indexOfNewLine == -1) ? originalCode.length : indexOfNewLine - 1;
          }
        }
        else if ((i+1 < originalCode.length) && (originalCode[i+1] == '*')) {
          // skip comment starting /*
          int indexOfNewLine = originalCode.indexOf('*/', i + 2);
          i = (indexOfNewLine == -1) ? originalCode.length : indexOfNewLine + 1;
        }
        else {
          // not comment
          modifiedCode += '/';
        }
      }
      else {
        modifiedCode += originalCode[i];
      }
    }
    /*
    YRITYS

    final code = utf8.encode(modifiedCode);
    final formattedCode = code.map((byte) => '\\x${byte.toRadixString(16).padLeft(2, '0')}').join('');
    modifiedCode = formattedCode;

     */
  }

  List <String> codeChunks() {
    List <String> code = [];
    int index = 0;
    while (index < modifiedCode.length) {
      code.add(modifiedCode.substring(
          index, min(index + codeChunkMaxSize, modifiedCode.length)));
      index += codeChunkMaxSize;
    }
    return code;
  }

}