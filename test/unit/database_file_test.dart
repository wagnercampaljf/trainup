import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainup/core/database/database_file.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('trainup_db_'));
  tearDown(() => dir.deleteSync(recursive: true));

  File file(String name) => File('${dir.path}/$name');

  test('renomeia o banco antigo e seus arquivos auxiliares', () async {
    file('minha_ficha.sqlite').writeAsStringSync('dados');
    file('minha_ficha.sqlite-journal').writeAsStringSync('journal');

    final path = await resolveDatabasePath(dir);

    expect(path, file('trainup.sqlite').path);
    expect(file('trainup.sqlite').readAsStringSync(), 'dados');
    expect(file('trainup.sqlite-journal').readAsStringSync(), 'journal');
    expect(file('minha_ficha.sqlite').existsSync(), isFalse);
    expect(file('minha_ficha.sqlite-journal').existsSync(), isFalse);
  });

  test('instalação nova usa o nome novo sem criar arquivos', () async {
    final path = await resolveDatabasePath(dir);
    expect(path, file('trainup.sqlite').path);
    expect(dir.listSync(), isEmpty);
  });

  test('com os dois bancos, usa o novo e não toca no antigo', () async {
    file('trainup.sqlite').writeAsStringSync('novo');
    file('minha_ficha.sqlite').writeAsStringSync('antigo');

    await resolveDatabasePath(dir);

    expect(file('trainup.sqlite').readAsStringSync(), 'novo');
    expect(file('minha_ficha.sqlite').readAsStringSync(), 'antigo');
  });

  test('conclui migração interrompida (auxiliar já renomeado)', () async {
    file('minha_ficha.sqlite').writeAsStringSync('dados');
    file('trainup.sqlite-journal').writeAsStringSync('journal');

    await resolveDatabasePath(dir);

    expect(file('trainup.sqlite').readAsStringSync(), 'dados');
    expect(file('trainup.sqlite-journal').readAsStringSync(), 'journal');
    expect(file('minha_ficha.sqlite').existsSync(), isFalse);
  });
}
