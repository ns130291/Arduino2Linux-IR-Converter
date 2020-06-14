// Arduino2Linux_IR_Converter
// Copyright (C) 2020  ns130291
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';
import 'package:args/args.dart';
import 'package:indent/indent.dart';

void main(List<String> arguments) {
  var parser = ArgParser()
    ..addFlag('raw',
        abbr: 'r',
        negatable: false,
        help: 'Outputs pulse and pause lines for use with ir-ctl')
    ..addOption('out',
        abbr: 'o', valueHelp: 'path', help: 'Output filename for raw option')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Shows this help text');

  var args;
  try {
    args = parser.parse(arguments);
  } catch (m) {
    print(m);
    print('use -h to show usage options');
    exit(64);
  }

  if (args['help']) {
    print(
        "Converts NEC IR codes from Arduino's IRremote library dump output to Linux ir-ctl format");
    print('');
    print('USAGE:');
    print('    Arduino2Linux_IR_Converter [-r [-o <path>]] <hex_code>');
    print('');
    print('OPTIONS:');
    print(parser.usage.indent(4));
  } else if (args.rest.isNotEmpty) {
    var code = int.tryParse(args.rest[0], radix: 16);
    code ??= int.tryParse(args.rest[0]);
    if (code == null) {
      stderr.writeln("couldn't parse code");
      exit(64);
    }

    if (args['raw']) {
      IOSink out = stdout;
      if (args['out'] != null) {
        out = File(args['out']).openWrite();
      }

      var code_bin = code.toRadixString(2).padLeft(32, '0');
      out.writeln('pulse 9000');
      out.writeln('space 4500');
      code_bin.split('').forEach((element) {
        out.writeln('pulse 562');
        if (element == '1') {
          out.writeln('space 1688');
        } else {
          out.writeln('space 563');
        }
      });
      out.writeln('pulse 563');
      out.close();
    } else {
      var code_hex = code.toRadixString(16).padLeft(8, '0').toUpperCase();
      var hex_list = code_hex.split('');
      print('nec:0x' + hex_list[7] + hex_list[6] + hex_list[3] + hex_list[2]);
    }
  } else {
    print('code argument missing');
    print('use -h to show usage options');
    exit(64);
  }
}
