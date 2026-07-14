import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pwbox/core/models/entry.dart';
import 'package:pwbox/core/models/group.dart';
import 'package:pwbox/core/services/database_service.dart';
import 'package:pwbox/core/services/theme_service.dart';
import 'package:pwbox/core/utils/constants.dart';
import 'package:pwbox/core/utils/shortcut_utils.dart';
import 'package:pwbox/core/utils/window_manager_helper.dart';
import 'package:pwbox/features/entry_editor/entry_editor_screen.dart';
import 'package:pwbox/features/home/home_view_model.dart';
import 'package:pwbox/features/home/widgets/entry_list_view.dart';
import 'package:pwbox/features/home/widgets/group_list_view.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/features/home/widgets/recycle_bin_view.dart';
import 'package:pwbox/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:split_view/split_view.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/services/locale_service.dart';

const String splitViewWeightsKey = 'split_view_weights';
const double kBorderRadiusLarge = 12.0;

class HomeScreen extends StatelessWidget {
  final DatabaseService databaseService;
  final VoidCallback onLock;

  const HomeScreen({
    super.key,
    required this.databaseService,
    required this.onLock,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(databaseService),
      child: HomeScreenContent(
        onLock: onLock,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final VoidCallback onLock;

  const HomeScreenContent({
    super.key,
    required this.onLock,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class LockDatabaseIntent extends Intent {
  const LockDatabaseIntent();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late final SharedPreferences _prefs;
  Timer? _autoLockTimer;
  Set<LogicalKeyboardKey>? _lockShortcut;
  late SplitViewController _splitViewController;
  Timer? _splitViewDebounce;
  late Future<void> _initializationFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _setupSplitView();
    _setupAutoLockTimer();
    _loadShortcutSettings();
  }

  @override
  void dispose() {
    _splitViewDebounce?.cancel();
    _autoLockTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setupSplitView() {
    final weights = _prefs.getStringList(splitViewWeightsKey) ?? ['0.3', '0.7'];
    _splitViewController = SplitViewController(
      weights: weights.map((w) => double.parse(w)).toList(),
      limits: [
        WeightLimit(min: 0.2, max: 0.5),
        WeightLimit(min: 0.5, max: 0.8),
      ],
    );
  }

  void _setupAutoLockTimer() {
    _autoLockTimer?.cancel();
    final timeoutMinutes = _prefs.getInt(autoLockTimeoutKey) ?? 0;
    if (timeoutMinutes > 0) {
      _autoLockTimer = Timer(Duration(minutes: timeoutMinutes), _lockDatabase);
    }
  }

  void _loadShortcutSettings() {
    final shortcutString = _prefs.getString(lockDatabaseShortcutKey);
    if (shortcutString != null) {
      final shortcut = ShortcutUtils.stringToShortcut(shortcutString);
      if (shortcut != null) {
        setState(() {
          _lockShortcut = shortcut;
        });
      }
    }
  }

  void _resetAutoLockTimer() {
    _setupAutoLockTimer();
  }

  Future<void> _lockDatabase() async {
    await WindowManagerHelper.setAuthWindowSize();
    _autoLockTimer?.cancel();
    await _saveSplitViewWeights();
    await Provider.of<HomeViewModel>(context, listen: false).databaseService.lock();
    widget.onLock();
  }

  Future<void> _saveSplitViewWeights() async {
    final newWeights = _splitViewController.weights.map((w) => w.toString()).toList();
    await _prefs.setStringList(splitViewWeightsKey, newWeights);
  }

  bool _isValidShortcut(Set<LogicalKeyboardKey> shortcut) {
    final modifierKeys = {
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
    };
    return shortcut.any((key) => !modifierKeys.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        if (_lockShortcut != null && _isValidShortcut(_lockShortcut!))
          LogicalKeySet.fromSet(_lockShortcut!): const LockDatabaseIntent(),
      },
      child: Actions(
        actions: {
          LockDatabaseIntent: CallbackAction<LockDatabaseIntent>(
            onInvoke: (intent) => _lockDatabase(),
          ),
        },
        child: GestureDetector(
          onTap: _resetAutoLockTimer,
          onPanDown: (_) => _resetAutoLockTimer(),
          onScaleStart: (_) => _resetAutoLockTimer(),
          child: Scaffold(
            body: FutureBuilder<void>(
              future: _initializationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(AppLocalizations.of(context)!.errorLoadingData(snapshot.error.toString())));
                }
                return _buildHomeContent(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        DragToMoveArea(
          child: Container(
            height: 20, // 这是一个隐形的、可拖拽的区域
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SplitView(
                  viewMode: SplitViewMode.Horizontal,
                  controller: _splitViewController,
                  gripSize: 4.0,
                  gripColor: Colors.grey.withOpacity(0.5),
                  gripColorActive: Colors.grey,
                  onWeightChanged: (weights) {
                    if (_splitViewDebounce?.isActive ?? false) _splitViewDebounce!.cancel();
                    _splitViewDebounce = Timer(const Duration(milliseconds: 500), _saveSplitViewWeights);
                  },
                  children: [
                    GroupTreeView(
                      groups: viewModel.groups,
                      isDarkMode: Provider.of<ThemeService>(context).isDarkMode,
                      onGroupSelected: (group) {
                        viewModel.onGroupSelected(group);
                        _resetAutoLockTimer();
                      },
                      onAddGroup: () => _showGroupNameDialog(context, null),
                      onRenameGroup: (group) => _showGroupNameDialog(context, group),
                      onDeleteGroup: (group) => _deleteGroup(context, group),
                      onAddSubGroup: (parent) => _showGroupNameDialog(context, null, parent: parent),
                      onAddEntryInGroup: (group) => _navigateToEntryEditor(context, group),
                      onMoveEntry: (entry, newGroup) {
                        viewModel.moveEntry(entry, newGroup);
                        _resetAutoLockTimer();
                      },
                      onRecycleBinSelected: () {
                        viewModel.onRecycleBinSelected();
                        _resetAutoLockTimer();
                      },
                      onSettingsSelected: () {
                        _navigateToSettings(context);
                        _resetAutoLockTimer();
                      },
                    ),
                    Consumer<HomeViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.isRecycleBinSelected) {
                          return RecycleBinView(
                            key: viewModel.recycleBinViewKey,
                            databaseService: viewModel.databaseService,
                            onRestore: (item) {
                              viewModel.restoreRecycleBinItem(item);
                              _resetAutoLockTimer();
                            },
                            onPermanentlyDelete: (item) {
                              viewModel.permanentlyDeleteRecycleBinItem(item);
                              _resetAutoLockTimer();
                            },
                          );
                        }
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: appLocalizations.searchEntries,
                                          prefixIcon: const Icon(Icons.search),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                          suffixIcon: viewModel.isSearchActive
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    viewModel.onSearchChanged('');
                                                  },
                                                )
                                              : null,
                                        ),
                                        onChanged: viewModel.onSearchChanged,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (viewModel.selectedGroup != null)
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(20), // 胶囊形状
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.folder_open_outlined,
                                            size: 16,
                                            color: theme.colorScheme.onSecondaryContainer,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            viewModel.selectedGroup!.name,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSecondaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    tooltip: appLocalizations.addNewEntryButton,
                                    onPressed: () => _navigateToEntryEditor(context, viewModel.selectedGroup),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.lock_outline),
                                    tooltip: appLocalizations.lockDatabaseTooltip,
                                    onPressed: _lockDatabase,
                                  ),
                                  IconButton(
                                    icon: Icon(viewModel.isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
                                    tooltip: viewModel.isGridView ? appLocalizations.listViewTooltip : appLocalizations.gridViewTooltip,
                                    onPressed: viewModel.toggleView,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: EntryListView(
                                entries: viewModel.entries,
                                groups: viewModel.groups,
                                isSearchActive: viewModel.isSearchActive,
                                selectedGroup: viewModel.selectedGroup,
                                onEdit: (entry) => _navigateToEntryEditor(context, null, entry: entry),
                                onDelete: (entry) {
                                  _deleteEntry(context, entry);
                                  _resetAutoLockTimer();
                                },
                                animatingDeletedEntryIds: viewModel.animatingDeletedEntryIds,
                                onAddEntry: () => _navigateToEntryEditor(context, viewModel.selectedGroup),
                                onClearSearch: () {
                                  viewModel.onSearchChanged('');
                                  _searchController.clear();
                                  _resetAutoLockTimer();
                                },
                                onMoveEntry: (entry, newGroup) {
                                  viewModel.moveEntry(entry, newGroup);
                                  _resetAutoLockTimer();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToEntryEditor(BuildContext context, Group? group, {Entry? entry}) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final localeService = Provider.of<LocaleService>(context, listen: false);

    showDialog<Entry>(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: homeViewModel),
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: localeService),
        ],
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
            child: EntryEditorScreen(
              groupId: group?.id ?? '',
              initialEntry: entry,
              databaseService: homeViewModel.databaseService,
            ),
          ),
        ),
      ),
    ).then((newEntry) {
      if (newEntry != null) {
        if (entry == null) {
          homeViewModel.addEntry(newEntry);
        } else {
          homeViewModel.updateEntry(newEntry);
        }
      }
    });
  }

  void _navigateToSettings(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final localeService = Provider.of<LocaleService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: homeViewModel),
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: localeService),
        ],
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: SettingsScreen(
              dbPath: homeViewModel.databaseService.dbPath,
              databaseService: homeViewModel.databaseService,
              themeService: themeService,
              localeService: localeService,
              is2faEnabled: homeViewModel.databaseService.is2faEnabled,
              onLockRequested: () => Navigator.of(context).pop(true),
              onShortcutChanged: _loadShortcutSettings,
            ),
          ),
        ),
      ),
    ).then((shouldLock) {
      _setupAutoLockTimer();
      if (shouldLock == true) {
        _lockDatabase();
      }
    });
  }

  Future<void> _deleteGroup(BuildContext context, Group group) async {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final confirmed = await _showConfirmationDialog(
      context,
      AppLocalizations.of(context)!.deleteGroup,
      AppLocalizations.of(context)!.deleteGroupConfirmationContent(group.name),
    );
    if (confirmed == true) {
      await viewModel.deleteGroup(group);
    }
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final confirmed = await _showConfirmationDialog(
      context,
      AppLocalizations.of(context)!.deleteEntryConfirmationTitle,
      AppLocalizations.of(context)!.deleteEntryConfirmationContent(entry.title),
    );
    if (confirmed == true) {
      await viewModel.deleteEntry(entry);
    }
  }

  Future<void> _showGroupNameDialog(BuildContext context, Group? group, {Group? parent}) async {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final nameController = TextEditingController(text: group?.name ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group == null
            ? (parent == null ? AppLocalizations.of(context)!.addGroup : AppLocalizations.of(context)!.addSubGroup)
            : AppLocalizations.of(context)!.renameGroup),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.groupNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.okButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newName = nameController.text;
      if (newName.isNotEmpty) {
        if (group == null) {
          await viewModel.addGroup(newName, parent?.id);
        } else {
          await viewModel.renameGroup(group, newName);
        }
      }
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.okButton),
          ),
        ],
      ),
    );
  }
}