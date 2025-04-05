import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/backup_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({Key? key}) : super(key: key);

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  List<File> _backupFiles = [];

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    if (kIsWeb) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _backupService.getBackupFiles();
      setState(() {
        _backupFiles = files;
      });
    } catch (e) {
      debugPrint('加载备份文件失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBackup() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Web平台不支持备份功能')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final backupPath = await _backupService.createBackup();
      if (backupPath != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('备份创建成功: $backupPath')));
          await _loadBackupFiles();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('备份创建失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('备份创建失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restoreFromBackup(File backupFile) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Web平台不支持恢复功能')));
      return;
    }

    // 显示确认对话框
    final shouldRestore = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('恢复备份'),
            content: const Text('恢复备份将覆盖现有数据，确定要继续吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定'),
              ),
            ],
          ),
    );

    if (shouldRestore != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _backupService.restoreFromBackup(backupFile);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('备份恢复成功，部分变更可能需要重启应用后生效')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('备份恢复失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('备份恢复失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importBackup() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Web平台不支持导入功能')));
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickMedia();

      if (file != null) {
        final fileToRestore = File(file.path);
        // 检查文件扩展名
        if (!file.path.toLowerCase().endsWith('.json')) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('请选择JSON备份文件')));
          }
          return;
        }
        await _restoreFromBackup(fileToRestore);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导入备份失败: $e')));
      }
    }
  }

  Future<void> _deleteBackup(File backupFile) async {
    if (kIsWeb) {
      return;
    }

    // 显示确认对话框
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('删除备份'),
            content: const Text('确定要删除这个备份吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _backupService.deleteBackupFile(backupFile);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('备份删除成功')));
          await _loadBackupFiles();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('备份删除失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('备份删除失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatBackupFileName(String path) {
    final fileName = path.split('/').last;
    final match = RegExp(
      r'pomodoro_backup_(\d{8}_\d{6})\.json',
    ).firstMatch(fileName);

    if (match != null && match.groupCount >= 1) {
      try {
        final dateStr = match.group(1)!;
        final date = DateFormat('yyyyMMdd_HHmmss').parse(dateStr);
        return DateFormat('yyyy年MM月dd日 HH:mm:ss').format(date);
      } catch (e) {
        return fileName;
      }
    }

    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 创建备份卡片
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.backup_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '创建备份',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '创建一个包含所有数据的备份，包括个人资料、设置、任务和历史记录。',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: kIsWeb ? null : _createBackup,
                                    icon: const Icon(Icons.save),
                                    label: const Text('创建备份'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 导入备份卡片
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.upload_file_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '导入备份',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '从外部文件导入备份，将覆盖现有数据。',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: kIsWeb ? null : _importBackup,
                                    icon: const Icon(Icons.file_upload),
                                    label: const Text('选择备份文件'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 备份列表
                    if (_backupFiles.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 16,
                          bottom: 8,
                        ),
                        child: Text(
                          '备份列表',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _backupFiles.length,
                        itemBuilder: (context, index) {
                          final backupFile = _backupFiles[index];
                          final timeStr = _formatBackupFileName(
                            backupFile.path,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.restore),
                              title: Text(timeStr),
                              subtitle: Text(
                                '点击恢复此备份',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteBackup(backupFile),
                                tooltip: '删除备份',
                              ),
                              onTap: () => _restoreFromBackup(backupFile),
                            ),
                          );
                        },
                      ),
                    ],

                    if (!kIsWeb && _backupFiles.isEmpty) ...[
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.backup_outlined,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '没有备份',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '点击上方的"创建备份"按钮创建一个备份',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (kIsWeb) ...[
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 64,
                              color: Colors.orange.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Web平台不支持备份功能',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '请使用移动端或桌面端应用使用备份功能',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
