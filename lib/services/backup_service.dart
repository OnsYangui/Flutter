import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class BackupService {
  Future<File> backupAllData() async {
    final Map<String, dynamic> backupData = {
      'createdAt': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(backupData);
    final directory = await getApplicationDocumentsDirectory();
    final backupFile = File(
        '${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await backupFile.writeAsString(jsonString);

    return backupFile;
  }

  Future<bool> restoreData(File backupFile) async {
    try {
      return true;
    } catch (e) {
      print('Erreur restauration: $e');
      return false;
    }
  }

  Future<void> autoBackup() async {
    await backupAllData();
  }

  Future<void> shareBackup() async {
    final backupFile = await backupAllData();
    await Share.shareXFiles(
      [XFile(backupFile.path)],
      text: 'Backup MediAssist - ${DateTime.now().toLocal()}',
    );
  }

  Future<void> cleanOldBackups({int keepCount = 5}) async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().whereType<File>();

    final backupFiles = files
        .where((file) =>
            file.path.contains('backup_') && file.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    if (backupFiles.length > keepCount) {
      for (int i = keepCount; i < backupFiles.length; i++) {
        await backupFiles[i].delete();
      }
    }
  }
}
