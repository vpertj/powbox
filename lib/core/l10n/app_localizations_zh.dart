// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settingsTitle => '设置';

  @override
  String get passwordStrength => '密码强度';

  @override
  String get language => '语言';

  @override
  String get strong => '强';

  @override
  String get medium => '中';

  @override
  String get weak => '弱';

  @override
  String get welcomeTitle => '欢迎使用 PwBox';

  @override
  String get createDatabase => '创建数据库';

  @override
  String get openDatabase => '打开数据库';

  @override
  String get unlockDatabaseTitle => '解锁数据库';

  @override
  String get unlockingDatabase => '正在加载数据库...';

  @override
  String get masterPassword => '主密码';

  @override
  String get unlockButton => '解锁';

  @override
  String get switchDatabaseButton => '切换数据库';

  @override
  String get enter2faCodeHint => '请输入您的双因素认证应用生成的6位验证码。';

  @override
  String get passwordCannotBeEmpty => '密码不能为空。';

  @override
  String get failedToOpenDatabase => '打开数据库失败：文件损坏。';

  @override
  String get invalidPasswordError => '密码无效。';

  @override
  String get selectDatabaseFile => '选择一个数据库文件';

  @override
  String get homeTitle => 'PwBox - 您的安全保险库';

  @override
  String get lockDatabaseTooltip => '锁定数据库';

  @override
  String get settingsTooltip => '设置';

  @override
  String get newGroupDialogTitle => '新建分组';

  @override
  String get renameGroupDialogTitle => '重命名分组';

  @override
  String get groupNameHint => '分组名称';

  @override
  String get databaseNameHint => '数据库名称';

  @override
  String get cancelButton => '取消';

  @override
  String get saveButton => '保存';

  @override
  String get addNewEntryButton => '添加新条目';

  @override
  String get noGroupSelectedErrorTitle => '未选择分组';

  @override
  String get noGroupSelectedErrorContent => '请在添加新条目之前选择一个分组。';

  @override
  String get deleteEntryConfirmationTitle => '删除条目？';

  @override
  String deleteEntryConfirmationContent(Object entryTitle) {
    return '您确定要删除 \"$entryTitle\" 吗？此操作无法撤销。';
  }

  @override
  String get deleteGroupConfirmationTitle => '删除分组？';

  @override
  String deleteGroupConfirmationContent(Object groupName) {
    return '您确定要删除 \"$groupName\" 吗？此操作无法撤销。';
  }

  @override
  String get cannotDeleteGroupErrorTitle => '无法删除分组';

  @override
  String get cannotDeleteGroupErrorContent => '此分组不为空。请先移动或删除所有条目。';

  @override
  String get cannotDeleteGroupWithSubgroupsErrorContent =>
      '此分组包含子分组。请先移动或删除所有子分组。';

  @override
  String get okButton => '确定';

  @override
  String get generalGroupName => '通用';

  @override
  String get searchEntries => '搜索条目';

  @override
  String get noSearchResults => '未找到搜索结果。';

  @override
  String get emptyGroup => '此分组为空。';

  @override
  String get addEntryHint => '点击右上角的“+”按钮添加新条目。';

  @override
  String get collapseGroup => '折叠分组';

  @override
  String get expandGroup => '展开分组';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get showPassword => '显示密码';

  @override
  String get copyUsernameTooltip => '复制用户名';

  @override
  String get copyPasswordTooltip => '复制密码';

  @override
  String get editButton => '编辑';

  @override
  String get deleteButton => '删除';

  @override
  String get usernameCopied => '用户名已复制到剪贴板！';

  @override
  String get passwordCopied => '密码已复制到剪贴板！';

  @override
  String get urlCopied => '网址已复制到剪贴板！';

  @override
  String get copyUrlTooltip => '复制网址';

  @override
  String get addEntryTitle => '添加新条目';

  @override
  String get editEntryTitle => '编辑条目';

  @override
  String get titleLabel => '标题';

  @override
  String get titleEmptyError => '标题不能为空';

  @override
  String get usernameLabel => '用户名';

  @override
  String get passwordLabel => '密码';

  @override
  String get urlLabel => '网址';

  @override
  String get attachmentsLabel => '附件';

  @override
  String get addAttachmentButton => '添加附件';

  @override
  String get saveEntryButton => '保存';

  @override
  String get noAttachmentsYet => '暂无附件。';

  @override
  String previewNotSupported(Object fileName) {
    return '不支持此文件类型的预览。\n\n$fileName';
  }

  @override
  String get closeButton => '关闭';

  @override
  String get generatePasswordTooltip => '生成密码';

  @override
  String get generalSettingsTab => '通用';

  @override
  String get securitySettingsTab => '安全';

  @override
  String get aboutSettingsTab => '关于';

  @override
  String get appVersion => '应用版本';

  @override
  String get databasePath => '数据库路径';

  @override
  String get newDatabaseEncryptionStrength => '新数据库加密强度';

  @override
  String get higherIterations => '更高的迭代次数更安全，但打开速度更慢。';

  @override
  String get fast => '快';

  @override
  String get balanced => '平衡';

  @override
  String get paranoid => '偏执';

  @override
  String get changeMasterPassword => '更改主密码';

  @override
  String get notYetImplemented => '尚未实现';

  @override
  String get aboutPwBox => '关于 PwBox';

  @override
  String get aboutPwBoxDescription => 'PwBox 是一个绝对安全可靠的跨平台密码管理器。';

  @override
  String get author => '作者';

  @override
  String get createDatabaseTitle => '创建新数据库';

  @override
  String get creatingDatabaseMessage =>
      '正在创建安全的数据库...\n这是一个一次性的操作，可能需要一点时间，请耐心等待。';

  @override
  String get masterPasswordLabel => '主密码';

  @override
  String get encryptionStrengthLabel => '加密强度';

  @override
  String get createAndSaveButton => '创建并保存';

  @override
  String get nextButton => '下一步';

  @override
  String get passwordEmptyError => '密码不能为空。';

  @override
  String get autoLockDatabase => '自动锁定数据库';

  @override
  String get never => '从不';

  @override
  String get minute => '分钟';

  @override
  String get oneMinute => '1 分钟';

  @override
  String get fiveMinutes => '5 分钟';

  @override
  String get fifteenMinutes => '15 分钟';

  @override
  String get openLocalDatabase => '打开本地数据库';

  @override
  String get openNetworkDatabase => '打开网络数据库';

  @override
  String get masterPasswordChangedSuccessfully => '主密码更改成功！';

  @override
  String get invalidCurrentPassword => '当前密码无效。';

  @override
  String get currentMasterPassword => '当前主密码';

  @override
  String get newMasterPassword => '新主密码';

  @override
  String get confirmNewMasterPassword => '确认新主密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get groups => '分组';

  @override
  String get addGroup => '添加分组';

  @override
  String get addSubgroup => '添加子分组';

  @override
  String get renameGroup => '重命名分组';

  @override
  String get deleteGroup => '删除分组';

  @override
  String get changeButton => '更改';

  @override
  String get passwordStrengthNone => '无密码';

  @override
  String get passwordStrengthWeak => '弱';

  @override
  String get passwordStrengthMedium => '中';

  @override
  String get passwordStrengthStrong => '强';

  @override
  String get downloadAttachmentTooltip => '下载';

  @override
  String get removeAttachmentTooltip => '移除';

  @override
  String get saveAttachmentAs => '另存附件为';

  @override
  String attachmentSavedSuccessfully(Object fileName) {
    return '附件 \"$fileName\" 保存成功！';
  }

  @override
  String failedToSaveAttachment(Object error, Object fileName) {
    return '附件 \"$fileName\" 保存失败: $error';
  }

  @override
  String get enableAutoBackup => '启用自动备份';

  @override
  String get settingsSaved => '设置已保存。';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文';

  @override
  String get passwordGeneratorIncludeUppercase => '包含大写字母 (A-Z)';

  @override
  String get passwordGeneratorIncludeLowercase => '包含小写字母 (a-z)';

  @override
  String get passwordGeneratorIncludeNumeric => '包含数字 (0-9)';

  @override
  String get passwordGeneratorIncludeSpecial => '包含特殊字符 (!@#...)';

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get backupSettings => '备份设置';

  @override
  String get databaseSettings => '数据库设置';

  @override
  String get securityFeatures => '安全功能';

  @override
  String get addSubGroup => '添加子分组';

  @override
  String get enable2fa => '启用双重认证';

  @override
  String get scanQrCodeWithAuthenticator => '使用您的认证器应用扫描二维码。';

  @override
  String get orEnterSecretManually => '或者手动输入此密钥：';

  @override
  String get enter2faCode => '输入 2FA 代码';

  @override
  String get verifyAndSaveButton => '验证并保存';

  @override
  String get invalid2faCode => '无效的 2FA 代码。';

  @override
  String get disable2fa => '禁用双重认证';

  @override
  String get disable2faConfirmation => '您确定要禁用双重认证吗？禁用后解锁数据库时将不再提示输入 2FA 代码。';

  @override
  String get disableButton => '禁用';

  @override
  String get twoFactorAuthDisabled => '双重认证已禁用。';

  @override
  String get twoFactorAuthRequired => '解锁此数据库需要双重认证。';

  @override
  String get verifyButton => '验证';

  @override
  String get fontSize => '字体大小';

  @override
  String get recycleBin => '回收站';

  @override
  String get emptyRecycleBin => '清空回收站';

  @override
  String get emptyRecycleBinConfirmation => '您确定要永久删除回收站中的所有项目吗？此操作无法撤销。';

  @override
  String get recycleBinIsEmpty => '回收站为空。';

  @override
  String get restore => '恢复';

  @override
  String get permanentlyDelete => '永久删除';

  @override
  String get permanentlyDeleteConfirmation => '您确定要永久删除此项目吗？此操作无法撤销。';

  @override
  String get recycleBinRetention => '回收站保留';

  @override
  String get sevenDays => '7 天';

  @override
  String get thirtyDays => '30 天';

  @override
  String get ninetyDays => '90 天';

  @override
  String get oneHundredEightyDays => '180 天';

  @override
  String get threeHundredSixtyFiveDays => '365 天';

  @override
  String get saving => '保存中...';

  @override
  String get openButton => '打开';

  @override
  String get unlockDatabase => '解锁数据库';

  @override
  String get switchDatabase => '切换数据库';

  @override
  String get selectDatabaseFolder => '选择保存数据库的文件夹';

  @override
  String get networkDatabaseNotImplemented => '网络数据库功能尚未实现。';

  @override
  String get basicInformation => '基本信息';

  @override
  String get groupLabel => '分组';

  @override
  String get notesLabel => '备注';

  @override
  String get generatePasswordButton => '生成密码';

  @override
  String get copyPasswordButton => '复制密码';

  @override
  String get generatedPassword => '生成的密码';

  @override
  String get passwordOptions => '密码选项';

  @override
  String get passwordLength => '密码长度';

  @override
  String get generateButton => '生成';

  @override
  String get useThisPasswordButton => '使用此密码';

  @override
  String get deletedAt => '删除于';

  @override
  String get lockDatabaseShortcut => '锁定数据库快捷键';

  @override
  String get shortcutNotSet => '未设置';

  @override
  String get pressShortcutToRecord => '按下快捷键进行录制';

  @override
  String get shortcutRecording => '正在录制快捷键... 按 Esc 取消';

  @override
  String get enter6DigitCode => '输入 6 位代码';

  @override
  String errorCreatingDatabase(Object error) {
    return '创建数据库时出错: $error';
  }

  @override
  String get selectDatabaseDialogTitle => '选择您的数据库文件 (database.pdbw)';

  @override
  String unexpectedErrorWithMessage(Object error) {
    return '发生意外错误: $error';
  }

  @override
  String get attachmentDataNotFound => '未找到此附件的数据。';

  @override
  String errorInitializingScreen(Object error) {
    return '初始化屏幕时出错: $error';
  }

  @override
  String get refreshButton => '刷新';

  @override
  String get entrySavedSuccessfully => '条目保存成功';

  @override
  String failedToSaveEntry(String error) {
    return '条目保存失败: $error';
  }

  @override
  String get backupCreatedSuccessfully => '初始备份创建成功';

  @override
  String backupFailed(String error) {
    return '备份失败: $error';
  }

  @override
  String lastBackupLabel(String datetime) {
    return '上次: $datetime';
  }

  @override
  String get confirmPassword => '确认密码';

  @override
  String get databaseNameEmptyHint => '留空以使用默认名称 \"pwbox\"';

  @override
  String get invalidDatabaseName => '数据库名称包含无效字符。请避免使用 <>:\"/\\|?*';

  @override
  String get databaseNameCannotStartWithDot => '数据库名称不能以点开头。';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get errorTitle => '错误';

  @override
  String get unexpectedError => '发生意外错误。';

  @override
  String errorLoadingAttachment(Object error) {
    return '加载附件时出错: $error';
  }

  @override
  String errorLoadingData(Object error) {
    return '加载数据时出错: $error';
  }

  @override
  String get aboutPwBoxLongDescription =>
      'PwBox 是一个免费、开源、跨平台的密码管理器，帮助您安全地存储和管理所有密码。';

  @override
  String failedToChangePassword(Object error) {
    return '更改主密码失败: $error';
  }

  @override
  String get settings => '设置';

  @override
  String get groupNotFound => '未分组';

  @override
  String deletedAtLabel(Object date) {
    return '删除于: $date';
  }

  @override
  String get shortcutCtrl => 'Ctrl';

  @override
  String get shortcutShift => 'Shift';

  @override
  String get shortcutAlt => 'Alt';

  @override
  String get shortcutMeta => '功能键';

  @override
  String get loading => '加载中...';

  @override
  String get errorOccurred => '发生错误';

  @override
  String errorSelectingFile(Object error) {
    return '选择文件时发生错误: $error';
  }

  @override
  String get fileTooLarge => '文件太大';

  @override
  String get fileTooLargeMessage => '所选文件超过10MB大小限制。';

  @override
  String get unsupportedFileType => '不支持的文件类型';

  @override
  String get unsupportedFileTypeMessage => '仅支持以下文件类型：TXT、PNG、JPG、GIF、PDF。';

  @override
  String get passwordGeneratorTitle => '密码生成器';

  @override
  String passwordLengthLabel(Object length) {
    return '密码长度: $length';
  }

  @override
  String get listViewTooltip => '切换到列表视图';

  @override
  String get gridViewTooltip => '切换到网格视图';
}
