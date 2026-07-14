import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PwBox'**
  String get welcomeTitle;

  /// No description provided for @createDatabase.
  ///
  /// In en, this message translates to:
  /// **'Create Database'**
  String get createDatabase;

  /// No description provided for @openDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Database'**
  String get openDatabase;

  /// No description provided for @unlockDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Database'**
  String get unlockDatabaseTitle;

  /// No description provided for @unlockingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Loading the database...'**
  String get unlockingDatabase;

  /// No description provided for @masterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get masterPassword;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @switchDatabaseButton.
  ///
  /// In en, this message translates to:
  /// **'Switch Database'**
  String get switchDatabaseButton;

  /// No description provided for @enter2faCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit verification code generated by your authenticator app.'**
  String get enter2faCodeHint;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty.'**
  String get passwordCannotBeEmpty;

  /// No description provided for @failedToOpenDatabase.
  ///
  /// In en, this message translates to:
  /// **'Failed to open database: Corrupted file.'**
  String get failedToOpenDatabase;

  /// No description provided for @invalidPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Invalid password.'**
  String get invalidPasswordError;

  /// No description provided for @selectDatabaseFile.
  ///
  /// In en, this message translates to:
  /// **'Select a database file'**
  String get selectDatabaseFile;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'PwBox - Your Secure Vault'**
  String get homeTitle;

  /// No description provided for @lockDatabaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lock Database'**
  String get lockDatabaseTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @newGroupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroupDialogTitle;

  /// No description provided for @renameGroupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Group'**
  String get renameGroupDialogTitle;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupNameHint;

  /// No description provided for @databaseNameHint.
  ///
  /// In en, this message translates to:
  /// **'Database Name'**
  String get databaseNameHint;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @addNewEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Entry'**
  String get addNewEntryButton;

  /// No description provided for @noGroupSelectedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No Group Selected'**
  String get noGroupSelectedErrorTitle;

  /// No description provided for @noGroupSelectedErrorContent.
  ///
  /// In en, this message translates to:
  /// **'Please select a group before adding a new entry.'**
  String get noGroupSelectedErrorContent;

  /// No description provided for @deleteEntryConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get deleteEntryConfirmationTitle;

  /// No description provided for @deleteEntryConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{entryTitle}\"? This action cannot be undone.'**
  String deleteEntryConfirmationContent(Object entryTitle);

  /// No description provided for @deleteGroupConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Group?'**
  String get deleteGroupConfirmationTitle;

  /// No description provided for @deleteGroupConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{groupName}\"? This action cannot be undone.'**
  String deleteGroupConfirmationContent(Object groupName);

  /// No description provided for @cannotDeleteGroupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot Delete Group'**
  String get cannotDeleteGroupErrorTitle;

  /// No description provided for @cannotDeleteGroupErrorContent.
  ///
  /// In en, this message translates to:
  /// **'This group is not empty. Please move or delete all entries first.'**
  String get cannotDeleteGroupErrorContent;

  /// No description provided for @cannotDeleteGroupWithSubgroupsErrorContent.
  ///
  /// In en, this message translates to:
  /// **'This group contains subgroups. Please move or delete all subgroups first.'**
  String get cannotDeleteGroupWithSubgroupsErrorContent;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @generalGroupName.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalGroupName;

  /// No description provided for @searchEntries.
  ///
  /// In en, this message translates to:
  /// **'Search Entries'**
  String get searchEntries;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results found.'**
  String get noSearchResults;

  /// No description provided for @emptyGroup.
  ///
  /// In en, this message translates to:
  /// **'This group is empty.'**
  String get emptyGroup;

  /// No description provided for @addEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Click the \'+\' button in the top right to add a new entry.'**
  String get addEntryHint;

  /// No description provided for @collapseGroup.
  ///
  /// In en, this message translates to:
  /// **'Collapse Group'**
  String get collapseGroup;

  /// No description provided for @expandGroup.
  ///
  /// In en, this message translates to:
  /// **'Expand Group'**
  String get expandGroup;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide Password'**
  String get hidePassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show Password'**
  String get showPassword;

  /// No description provided for @copyUsernameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy Username'**
  String get copyUsernameTooltip;

  /// No description provided for @copyPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy Password'**
  String get copyPasswordTooltip;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @usernameCopied.
  ///
  /// In en, this message translates to:
  /// **'Username copied to clipboard!'**
  String get usernameCopied;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied to clipboard!'**
  String get passwordCopied;

  /// No description provided for @urlCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard!'**
  String get urlCopied;

  /// No description provided for @copyUrlTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get copyUrlTooltip;

  /// No description provided for @addEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Entry'**
  String get addEntryTitle;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntryTitle;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get titleEmptyError;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @attachmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsLabel;

  /// No description provided for @addAttachmentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachmentButton;

  /// No description provided for @saveEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveEntryButton;

  /// No description provided for @noAttachmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No attachments yet.'**
  String get noAttachmentsYet;

  /// No description provided for @previewNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Preview for this file type is not supported.\n\n{fileName}'**
  String previewNotSupported(Object fileName);

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @generatePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate Password'**
  String get generatePasswordTooltip;

  /// No description provided for @generalSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettingsTab;

  /// No description provided for @securitySettingsTab.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySettingsTab;

  /// No description provided for @aboutSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSettingsTab;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @databasePath.
  ///
  /// In en, this message translates to:
  /// **'Database Path'**
  String get databasePath;

  /// No description provided for @newDatabaseEncryptionStrength.
  ///
  /// In en, this message translates to:
  /// **'New Database Encryption Strength'**
  String get newDatabaseEncryptionStrength;

  /// No description provided for @higherIterations.
  ///
  /// In en, this message translates to:
  /// **'Higher iterations are more secure but slower to open.'**
  String get higherIterations;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @paranoid.
  ///
  /// In en, this message translates to:
  /// **'Paranoid'**
  String get paranoid;

  /// No description provided for @changeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Master Password'**
  String get changeMasterPassword;

  /// No description provided for @notYetImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not yet implemented'**
  String get notYetImplemented;

  /// No description provided for @aboutPwBox.
  ///
  /// In en, this message translates to:
  /// **'About PwBox'**
  String get aboutPwBox;

  /// No description provided for @aboutPwBoxDescription.
  ///
  /// In en, this message translates to:
  /// **'PwBox is a Absolutely safe and secure password manager for cross-platform compatibility.'**
  String get aboutPwBoxDescription;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @createDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Database'**
  String get createDatabaseTitle;

  /// No description provided for @creatingDatabaseMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating secure database...\nThis is a one-time operation and may take a minute.'**
  String get creatingDatabaseMessage;

  /// No description provided for @masterPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get masterPasswordLabel;

  /// No description provided for @encryptionStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Encryption Strength'**
  String get encryptionStrengthLabel;

  /// No description provided for @createAndSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Create and Save'**
  String get createAndSaveButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @passwordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty.'**
  String get passwordEmptyError;

  /// No description provided for @autoLockDatabase.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock database'**
  String get autoLockDatabase;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute(s)'**
  String get minute;

  /// No description provided for @oneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get oneMinute;

  /// No description provided for @fiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get fiveMinutes;

  /// No description provided for @fifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get fifteenMinutes;

  /// No description provided for @openLocalDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Local Database'**
  String get openLocalDatabase;

  /// No description provided for @openNetworkDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Network Database'**
  String get openNetworkDatabase;

  /// No description provided for @masterPasswordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Master password changed successfully!'**
  String get masterPasswordChangedSuccessfully;

  /// No description provided for @invalidCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid current password.'**
  String get invalidCurrentPassword;

  /// No description provided for @currentMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Master Password'**
  String get currentMasterPassword;

  /// No description provided for @newMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'New Master Password'**
  String get newMasterPassword;

  /// No description provided for @confirmNewMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Master Password'**
  String get confirmNewMasterPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroup;

  /// No description provided for @addSubgroup.
  ///
  /// In en, this message translates to:
  /// **'Add Subgroup'**
  String get addSubgroup;

  /// No description provided for @renameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename Group'**
  String get renameGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @passwordStrengthNone.
  ///
  /// In en, this message translates to:
  /// **'No password'**
  String get passwordStrengthNone;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @downloadAttachmentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadAttachmentTooltip;

  /// No description provided for @removeAttachmentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAttachmentTooltip;

  /// No description provided for @saveAttachmentAs.
  ///
  /// In en, this message translates to:
  /// **'Save Attachment As'**
  String get saveAttachmentAs;

  /// No description provided for @attachmentSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Attachment \"{fileName}\" saved successfully!'**
  String attachmentSavedSuccessfully(Object fileName);

  /// No description provided for @failedToSaveAttachment.
  ///
  /// In en, this message translates to:
  /// **'Failed to save attachment \"{fileName}\": {error}'**
  String failedToSaveAttachment(Object error, Object fileName);

  /// No description provided for @enableAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Enable Automatic Backup'**
  String get enableAutoBackup;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @passwordGeneratorIncludeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include Uppercase (A-Z)'**
  String get passwordGeneratorIncludeUppercase;

  /// No description provided for @passwordGeneratorIncludeLowercase.
  ///
  /// In en, this message translates to:
  /// **'Include Lowercase (a-z)'**
  String get passwordGeneratorIncludeLowercase;

  /// No description provided for @passwordGeneratorIncludeNumeric.
  ///
  /// In en, this message translates to:
  /// **'Include Numbers (0-9)'**
  String get passwordGeneratorIncludeNumeric;

  /// No description provided for @passwordGeneratorIncludeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Include Special Characters (!@#...)'**
  String get passwordGeneratorIncludeSpecial;

  /// No description provided for @appearanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance Settings'**
  String get appearanceSettings;

  /// No description provided for @backupSettings.
  ///
  /// In en, this message translates to:
  /// **'Backup Settings'**
  String get backupSettings;

  /// No description provided for @databaseSettings.
  ///
  /// In en, this message translates to:
  /// **'Database Settings'**
  String get databaseSettings;

  /// No description provided for @securityFeatures.
  ///
  /// In en, this message translates to:
  /// **'Security Features'**
  String get securityFeatures;

  /// No description provided for @addSubGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Subgroup'**
  String get addSubGroup;

  /// No description provided for @enable2fa.
  ///
  /// In en, this message translates to:
  /// **'Enable Two-Factor Authentication'**
  String get enable2fa;

  /// No description provided for @scanQrCodeWithAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with your authenticator app.'**
  String get scanQrCodeWithAuthenticator;

  /// No description provided for @orEnterSecretManually.
  ///
  /// In en, this message translates to:
  /// **'Or enter this secret manually:'**
  String get orEnterSecretManually;

  /// No description provided for @enter2faCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 2FA Code'**
  String get enter2faCode;

  /// No description provided for @verifyAndSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Verify and Save'**
  String get verifyAndSaveButton;

  /// No description provided for @invalid2faCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid 2FA code.'**
  String get invalid2faCode;

  /// No description provided for @disable2fa.
  ///
  /// In en, this message translates to:
  /// **'Disable Two-Factor Authentication'**
  String get disable2fa;

  /// No description provided for @disable2faConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable two-factor authentication? You will no longer be prompted for a 2FA code when unlocking your database.'**
  String get disable2faConfirmation;

  /// No description provided for @disableButton.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disableButton;

  /// No description provided for @twoFactorAuthDisabled.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication has been disabled.'**
  String get twoFactorAuthDisabled;

  /// No description provided for @twoFactorAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication is required to unlock this database.'**
  String get twoFactorAuthRequired;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @recycleBin.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get recycleBin;

  /// No description provided for @emptyRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Empty Recycle Bin'**
  String get emptyRecycleBin;

  /// No description provided for @emptyRecycleBinConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all items in the recycle bin? This action cannot be undone.'**
  String get emptyRecycleBinConfirmation;

  /// No description provided for @recycleBinIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is empty.'**
  String get recycleBinIsEmpty;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @permanentlyDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get permanentlyDelete;

  /// No description provided for @permanentlyDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this item? This action cannot be undone.'**
  String get permanentlyDeleteConfirmation;

  /// No description provided for @recycleBinRetention.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin Retention'**
  String get recycleBinRetention;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get sevenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get thirtyDays;

  /// No description provided for @ninetyDays.
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get ninetyDays;

  /// No description provided for @oneHundredEightyDays.
  ///
  /// In en, this message translates to:
  /// **'180 Days'**
  String get oneHundredEightyDays;

  /// No description provided for @threeHundredSixtyFiveDays.
  ///
  /// In en, this message translates to:
  /// **'365 Days'**
  String get threeHundredSixtyFiveDays;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @openButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openButton;

  /// No description provided for @unlockDatabase.
  ///
  /// In en, this message translates to:
  /// **'Unlock Database'**
  String get unlockDatabase;

  /// No description provided for @switchDatabase.
  ///
  /// In en, this message translates to:
  /// **'Switch Database'**
  String get switchDatabase;

  /// No description provided for @selectDatabaseFolder.
  ///
  /// In en, this message translates to:
  /// **'Select a folder to save your database'**
  String get selectDatabaseFolder;

  /// No description provided for @networkDatabaseNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Network database functionality is not yet implemented.'**
  String get networkDatabaseNotImplemented;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @generatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Password'**
  String get generatePasswordButton;

  /// No description provided for @copyPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Copy Password'**
  String get copyPasswordButton;

  /// No description provided for @generatedPassword.
  ///
  /// In en, this message translates to:
  /// **'Generated Password'**
  String get generatedPassword;

  /// No description provided for @passwordOptions.
  ///
  /// In en, this message translates to:
  /// **'Password Options'**
  String get passwordOptions;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password Length'**
  String get passwordLength;

  /// No description provided for @generateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateButton;

  /// No description provided for @useThisPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Use This Password'**
  String get useThisPasswordButton;

  /// No description provided for @deletedAt.
  ///
  /// In en, this message translates to:
  /// **'Deleted At'**
  String get deletedAt;

  /// No description provided for @lockDatabaseShortcut.
  ///
  /// In en, this message translates to:
  /// **'Lock Database Shortcut'**
  String get lockDatabaseShortcut;

  /// No description provided for @shortcutNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get shortcutNotSet;

  /// No description provided for @pressShortcutToRecord.
  ///
  /// In en, this message translates to:
  /// **'Press shortcut to record'**
  String get pressShortcutToRecord;

  /// No description provided for @shortcutRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording shortcut... Press Esc to cancel'**
  String get shortcutRecording;

  /// No description provided for @enter6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get enter6DigitCode;

  /// No description provided for @errorCreatingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Error creating database: {error}'**
  String errorCreatingDatabase(Object error);

  /// No description provided for @selectDatabaseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your database file (database.pdbw)'**
  String get selectDatabaseDialogTitle;

  /// No description provided for @unexpectedErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedErrorWithMessage(Object error);

  /// No description provided for @attachmentDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Data for this attachment not found.'**
  String get attachmentDataNotFound;

  /// No description provided for @errorInitializingScreen.
  ///
  /// In en, this message translates to:
  /// **'Error initializing screen: {error}'**
  String errorInitializingScreen(Object error);

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// Snackbar message shown when an entry is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Entry saved successfully'**
  String get entrySavedSuccessfully;

  /// Snackbar message shown when saving an entry fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save entry: {error}'**
  String failedToSaveEntry(String error);

  /// Snackbar message shown when the initial backup is created successfully
  ///
  /// In en, this message translates to:
  /// **'Initial backup created successfully'**
  String get backupCreatedSuccessfully;

  /// Snackbar message shown when a backup fails
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// Label for the last backup time
  ///
  /// In en, this message translates to:
  /// **'Last: {datetime}'**
  String lastBackupLabel(String datetime);

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @databaseNameEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use default name \"pwbox\"'**
  String get databaseNameEmptyHint;

  /// No description provided for @invalidDatabaseName.
  ///
  /// In en, this message translates to:
  /// **'Database name contains invalid characters. Please avoid using <>:\"/\\|?*'**
  String get invalidDatabaseName;

  /// No description provided for @databaseNameCannotStartWithDot.
  ///
  /// In en, this message translates to:
  /// **'Database name cannot start with a dot.'**
  String get databaseNameCannotStartWithDot;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @errorLoadingAttachment.
  ///
  /// In en, this message translates to:
  /// **'Error loading attachment: {error}'**
  String errorLoadingAttachment(Object error);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @aboutPwBoxLongDescription.
  ///
  /// In en, this message translates to:
  /// **'PwBox is a free, open-source, cross-platform password manager that helps you securely store and manage all your passwords.'**
  String get aboutPwBoxLongDescription;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change master password: {error}'**
  String failedToChangePassword(Object error);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get groupNotFound;

  /// No description provided for @deletedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleted At: {date}'**
  String deletedAtLabel(Object date);

  /// No description provided for @shortcutCtrl.
  ///
  /// In en, this message translates to:
  /// **'Ctrl'**
  String get shortcutCtrl;

  /// No description provided for @shortcutShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shortcutShift;

  /// No description provided for @shortcutAlt.
  ///
  /// In en, this message translates to:
  /// **'Alt'**
  String get shortcutAlt;

  /// No description provided for @shortcutMeta.
  ///
  /// In en, this message translates to:
  /// **'Meta'**
  String get shortcutMeta;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error Occurred'**
  String get errorOccurred;

  /// No description provided for @errorSelectingFile.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while selecting the file: {error}'**
  String errorSelectingFile(Object error);

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File Too Large'**
  String get fileTooLarge;

  /// No description provided for @fileTooLargeMessage.
  ///
  /// In en, this message translates to:
  /// **'The selected file exceeds the 10MB size limit.'**
  String get fileTooLargeMessage;

  /// No description provided for @unsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported File Type'**
  String get unsupportedFileType;

  /// No description provided for @unsupportedFileTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Only the following file types are supported: TXT, PNG, JPG, GIF, PDF.'**
  String get unsupportedFileTypeMessage;

  /// No description provided for @passwordGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Generator'**
  String get passwordGeneratorTitle;

  /// No description provided for @passwordLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Password Length: {length}'**
  String passwordLengthLabel(Object length);

  /// No description provided for @listViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to List View'**
  String get listViewTooltip;

  /// No description provided for @gridViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to Grid View'**
  String get gridViewTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
