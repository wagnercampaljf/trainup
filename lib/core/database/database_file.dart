import 'dart:io';

/// Nome do banco: arquivo `<nome>.sqlite` no diretório de documentos do app.
const databaseName = 'trainup';

/// Nome do arquivo usado antes de o app se chamar TrainUp ("Minha Ficha").
const legacyDatabaseName = 'minha_ficha';

/// Arquivos auxiliares do SQLite que acompanham o banco. O arquivo principal
/// (sufixo vazio) é o último a ser renomeado: se a migração for interrompida,
/// ele continua com o nome antigo e a próxima abertura conclui o processo.
const _sidecars = ['-journal', '-wal', '-shm', ''];

/// Caminho do banco em [directory], migrando o arquivo do nome antigo.
///
/// Se existir apenas o banco antigo, ele e seus arquivos auxiliares são
/// renomeados antes da abertura, sem perda de dados. Se os dois existirem, o
/// novo é usado e o antigo não é tocado.
Future<String> resolveDatabasePath(Directory directory) async {
  String pathOf(String name, String suffix) =>
      '${directory.path}${Platform.pathSeparator}$name.sqlite$suffix';

  final current = File(pathOf(databaseName, ''));
  final legacy = File(pathOf(legacyDatabaseName, ''));
  if (!current.existsSync() && legacy.existsSync()) {
    for (final suffix in _sidecars) {
      final file = File(pathOf(legacyDatabaseName, suffix));
      if (file.existsSync()) await file.rename(pathOf(databaseName, suffix));
    }
  }
  return current.path;
}
