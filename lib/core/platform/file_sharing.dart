import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Arquivo escolhido pelo usuário.
typedef PickedFile = ({String name, Uint8List bytes});

/// Compartilhamento e escolha de arquivos pelo sistema (WhatsApp, e-mail,
/// Drive…). Nada é enviado pelo app: o usuário escolhe o destino.
///
/// Isolado em um provider para que os testes usem uma versão falsa.
class FileSharing {
  const FileSharing();

  /// Abre a folha de compartilhamento do sistema com um arquivo.
  Future<void> shareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? text,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
        fileNameOverrides: [fileName],
        text: text,
      ),
    );
  }

  /// Abre o seletor de arquivos do sistema. `null` se o usuário cancelar.
  Future<PickedFile?> pickFile() async {
    // Sem filtro de tipo: arquivos recebidos por apps de mensagem nem sempre
    // chegam com o tipo "application/json". O conteúdo é validado depois.
    final file = await openFile();
    if (file == null) return null;
    return (name: file.name, bytes: await file.readAsBytes());
  }
}

final fileSharingProvider = Provider<FileSharing>((ref) => const FileSharing());
