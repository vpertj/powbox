import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/models/attachment.dart';
import 'package:pwbox/core/models/entry.dart';
import 'package:pwbox/core/models/group.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/widgets/password_strength_indicator.dart';
import 'package:pwbox/features/password_generator/password_generator_screen.dart';
import 'package:uuid/uuid.dart';

/// 条目编辑器屏幕
/// 用于创建或编辑密码条目
class EntryEditorScreen extends StatefulWidget {
  /// 初始条目（可选，用于编辑现有条目）
  final Entry? initialEntry;

  /// 分组ID
  final String groupId;

  /// 数据库服务实例
  final DatabaseService databaseService;

  /// 构造函数
  ///
  /// [key] 组件键
  /// [initialEntry] 初始条目
  /// [groupId] 分组ID
  /// [databaseService] 数据库服务实例
  const EntryEditorScreen({
    super.key,
    this.initialEntry,
    required this.groupId,
    required this.databaseService,
  });

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  final _passwordNotifier = ValueNotifier<String>('');
  late TextEditingController _urlController;
  late TextEditingController _notesController;
  late List<Attachment> _attachments;
  Group? _selectedGroup;
  List<Group> _groups = [];
  Future<void>? _groupsInitializationFuture;
  AppLocalizations? _appLocalizations;
  bool _isNewEntry = true;
  bool _isPasswordVisible = false;
  bool _isSaving = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isNewEntry = widget.initialEntry == null;
    _attachments = List<Attachment>.from(widget.initialEntry?.attachments ?? []);
    _titleController = TextEditingController(text: widget.initialEntry?.title ?? '');
    _usernameController = TextEditingController(text: widget.initialEntry?.username ?? '');
    _passwordController = TextEditingController(text: widget.initialEntry?.password ?? '')
      ..addListener(() {
        _passwordNotifier.value = _passwordController.text;
      });
    _urlController = TextEditingController(text: widget.initialEntry?.url ?? '');
    _notesController = TextEditingController(text: widget.initialEntry?.notes ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appLocalizations == null) {
      _appLocalizations = AppLocalizations.of(context)!;
      _groupsInitializationFuture = _loadGroups();
    }
  }

  Future<void> _loadGroups() async {
    final groupsData = await widget.databaseService.getAllGroups();
    _groups = groupsData.map((groupData) => Group.fromJson(groupData)).toList();
    if (widget.initialEntry != null) {
      _selectedGroup = _groups.firstWhere(
        (group) => group.id == widget.initialEntry!.groupId,
        orElse: () {
          debugPrint('警告: 未找到ID为: ${widget.initialEntry!.groupId} 的分组');
          return Group(id: '', name: _appLocalizations!.groupNotFound);
        },
      );
    } else if (_groups.isNotEmpty) {
      _selectedGroup = _groups.firstWhere(
        (group) => group.id == widget.groupId,
        orElse: () => _groups.first,
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordNotifier.dispose();
    _titleController.dispose();
    _usernameController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final entry = Entry(
        id: widget.initialEntry?.id ?? _uuid.v4(),
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        url: _urlController.text,
        groupId: _selectedGroup?.id ?? widget.groupId,
        notes: _notesController.text,
        attachments: _attachments,
      );
      Navigator.of(context).pop(entry);
    }
  }

  Future<void> _addAttachment() async {
    const int maxFileSizeInBytes = 10 * 1024 * 1024;
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(withData: true);
    } catch (e) {
      if (mounted) {
        _showErrorDialog(_appLocalizations!.errorOccurred, _appLocalizations!.errorSelectingFile(e.toString()));
      }
      return;
    }

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.size > maxFileSizeInBytes) {
        if (mounted) {
          _showErrorDialog(_appLocalizations!.fileTooLarge, _appLocalizations!.fileTooLargeMessage);
        }
        return;
      }
      if (file.path == null) {
        if (mounted) {
          _showErrorDialog(_appLocalizations!.errorOccurred, _appLocalizations!.errorSelectingFile("文件路径为空"));
        }
        return;
      }
      final mimeType = lookupMimeType(file.name, headerBytes: file.bytes);
      final fileBytes = await File(file.path!).readAsBytes();
      setState(() {
        _attachments.add(
          Attachment(
            id: _uuid.v4(),
            fileName: file.name,
            mimeType: mimeType ?? 'application/octet-stream',
            data: fileBytes,
          ),
        );
      });
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_appLocalizations!.okButton),
          ),
        ],
      ),
    );
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments.removeWhere((a) => a.id == id);
    });
  }

  void _previewAttachment(Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) {
        final futureAttachmentData =
            attachment.data.isNotEmpty ? Future.value(attachment.data) : widget.databaseService.getAttachmentData(attachment.id);
        return FutureBuilder<Uint8List?>(
          future: futureAttachmentData,
          builder: (context, snapshot) {
            Widget content;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              content = Text(_appLocalizations!.errorLoadingAttachment(snapshot.error.toString()));
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              if (attachment.mimeType.startsWith('image/')) {
                content = Image.memory(data);
              } else if (attachment.mimeType == 'text/plain') {
                content = SingleChildScrollView(child: Text(utf8.decode(data)));
              } else {
                content = Text(_appLocalizations!.previewNotSupported(attachment.fileName));
              }
            } else {
              content = Text(_appLocalizations!.attachmentDataNotFound);
            }
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              title: Text(attachment.fileName),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                child: content,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(_appLocalizations!.closeButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String labelText, {Widget? prefixIcon, Widget? suffixIcon}) {
    const borderRadius = BorderRadius.all(Radius.circular(12.0));
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(borderRadius: borderRadius),
      enabledBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.blue),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.red),
      ),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = _appLocalizations ?? AppLocalizations.of(context)!;
    return FutureBuilder<void>(
      future: _groupsInitializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                appLocalizations.errorLoadingData(snapshot.error.toString()),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 48.0,
            title: Text(_isNewEntry ? appLocalizations.addEntryTitle : appLocalizations.editEntryTitle),
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalizations.basicInformation, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _titleController,
                          decoration: _buildInputDecoration(
                            appLocalizations.titleLabel,
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) => value!.isEmpty ? appLocalizations.titleEmptyError : null,
                        ),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          controller: _usernameController,
                          decoration: _buildInputDecoration(
                            appLocalizations.usernameLabel,
                            prefixIcon: const Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            appLocalizations.passwordLabel,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.key),
                                  onPressed: _openPasswordGenerator,
                                  tooltip: appLocalizations.generatePasswordTooltip,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<String>(
                          valueListenable: _passwordNotifier,
                          builder: (context, password, child) {
                            return PasswordStrengthIndicator(password: password);
                          },
                        ),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          controller: _urlController,
                          decoration: _buildInputDecoration(
                            appLocalizations.urlLabel,
                            prefixIcon: const Icon(Icons.link),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalizations.notesLabel, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _notesController,
                          decoration: _buildInputDecoration(appLocalizations.notesLabel),
                          maxLines: 5,
                          minLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalizations.attachmentsLabel, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          height: 200,
                          child: _buildAttachmentsList(),
                        ),
                        const SizedBox(height: 16.0),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: Text(appLocalizations.addAttachmentButton),
                          onPressed: _addAttachment,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(appLocalizations.cancelButton),
                ),
                const SizedBox(width: 8.0),
                FilledButton(
                  onPressed: _isSaving ? null : _saveForm,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSaving)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      if (_isSaving) const SizedBox(width: 8),
                      Text(_isSaving ? appLocalizations.saving : appLocalizations.saveEntryButton),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentsList() {
    if (_attachments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(_appLocalizations!.noAttachmentsYet),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        final attachment = _attachments[index];
        return ListTile(
          leading: Icon(_getIconForMimeType(attachment.mimeType)),
          title: Text(attachment.fileName, overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                tooltip: _appLocalizations!.downloadAttachmentTooltip,
                onPressed: () => _downloadAttachment(attachment),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                tooltip: _appLocalizations!.removeAttachmentTooltip,
                onPressed: () => _removeAttachment(attachment.id),
              ),
            ],
          ),
          onTap: () => _previewAttachment(attachment),
        );
      },
    );
  }

  IconData _getIconForMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType == 'text/plain') return Icons.description_outlined;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (mimeType == 'application/msword' ||
        mimeType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return Icons.article_outlined;
    }
    if (mimeType == 'application/vnd.ms-excel' ||
        mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return Icons.table_chart_outlined;
    }
    return Icons.attach_file_outlined;
  }

  void _openPasswordGenerator() async {
    final generatedPassword = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: const SizedBox(
          width: 400,
          height: 500,
          child: ScaffoldMessenger(child: PasswordGeneratorScreen()),
        ),
      ),
    );

    if (!mounted) return;
    if (generatedPassword != null && generatedPassword.isNotEmpty) {
      setState(() {
        _passwordController.text = generatedPassword;
      });
    }
  }

  Future<void> _downloadAttachment(Attachment attachment) async {
    try {
      final dataToSave =
          attachment.data.isNotEmpty ? attachment.data : await widget.databaseService.getAttachmentData(attachment.id);

      if (!mounted) return;
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: _appLocalizations!.saveAttachmentAs,
        fileName: attachment.fileName,
      );

      if (!mounted) return;
      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(dataToSave ?? Uint8List(0));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_appLocalizations!.attachmentSavedSuccessfully(attachment.fileName)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_appLocalizations!.failedToSaveAttachment(attachment.fileName, e.toString())),
          ),
        );
      }
    }
  }
}
