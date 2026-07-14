import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:pwbox/core/models/entry.dart';
import 'package:pwbox/core/models/group.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:pwbox/features/home/home_view_model.dart';

class GroupTreeNode {
  final Group group;
  final List<GroupTreeNode> children;

  GroupTreeNode({required this.group, required this.children});
}

class GroupTreeView extends StatefulWidget {
  final List<Group> groups;
  final Group? selectedGroup;
  final void Function(Group) onGroupSelected;
  final VoidCallback onAddGroup;
  final void Function(Group) onAddSubGroup;
  final void Function(Group) onRenameGroup;
  final void Function(Group) onAddEntryInGroup;
  final void Function(Entry, Group) onMoveEntry;
  final void Function(Group) onDeleteGroup;
  final VoidCallback onRecycleBinSelected;
  final VoidCallback onSettingsSelected;
  final bool isDarkMode;

  const GroupTreeView({
    super.key,
    required this.groups,
    this.selectedGroup,
    required this.onGroupSelected,
    required this.onAddGroup,
    required this.onAddSubGroup,
    required this.onRenameGroup,
    required this.onAddEntryInGroup,
    required this.onMoveEntry,
    required this.onDeleteGroup,
    required this.onRecycleBinSelected,
    required this.onSettingsSelected,
    required this.isDarkMode,
  });

  @override
  State<GroupTreeView> createState() => _GroupTreeViewState();
}

class _GroupTreeViewState extends State<GroupTreeView> {
  late final TreeController<GroupTreeNode> _treeController;
  late List<GroupTreeNode> _rootNodes;

  @override
  void initState() {
    super.initState();
    _rootNodes = _buildTree();
    _treeController = TreeController<GroupTreeNode>(
      roots: _rootNodes,
      childrenProvider: (node) => node.children,
    );

    if (_rootNodes.isNotEmpty) {
      _treeController.expand(_rootNodes.first);
    }
  }

  @override
  void didUpdateWidget(covariant GroupTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groups != oldWidget.groups) {
      setState(() {
        _rootNodes = _buildTree();
        _treeController.roots = _rootNodes;
      });
    }
  }

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  List<GroupTreeNode> _buildTree() {
    final Map<String?, List<Group>> groupsByParentId = {};
    for (final group in widget.groups) {
      groupsByParentId.putIfAbsent(group.parentId, () => []).add(group);
    }

    List<GroupTreeNode> buildNodes(String? parentId) {
      final children = groupsByParentId[parentId] ?? [];
      children.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      return children.map((group) {
        return GroupTreeNode(group: group, children: buildNodes(group.id));
      }).toList();
    }

    return buildNodes(null);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    appLocalizations.groups,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (constraints.maxWidth < 180)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: widget.onAddGroup,
                    tooltip: appLocalizations.addGroup,
                  )
                else
                  FilledButton.icon(
                    onPressed: widget.onAddGroup,
                    icon: const Icon(Icons.add),
                    label: Text(appLocalizations.addGroup),
                  ),
              ],
            );
          }),
        ),
        const Divider(height: 1),
        Expanded(
          child: _rootNodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_off_outlined,
                        size: 48.0,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        appLocalizations.emptyGroup,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : TreeView<GroupTreeNode>(
                  treeController: _treeController,
                  nodeBuilder: (context, entry) {
                    return _GroupTile(
                      treeEntry: entry,
                      treeController: _treeController,
                      selectedGroup: widget.selectedGroup,
                      onGroupSelected: widget.onGroupSelected,
                      onMoveEntry: widget.onMoveEntry,
                      onAddSubGroup: widget.onAddSubGroup,
                      onAddEntryInGroup: widget.onAddEntryInGroup,
                      onRenameGroup: widget.onRenameGroup,
                      onDeleteGroup: widget.onDeleteGroup,
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: appLocalizations.settingsTooltip,
                  onPressed: widget.onSettingsSelected,
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: appLocalizations.recycleBin,
                  onPressed: widget.onRecycleBinSelected,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupTile extends StatefulWidget {
  final TreeEntry<GroupTreeNode> treeEntry;
  final TreeController<GroupTreeNode> treeController;
  final Group? selectedGroup;
  final void Function(Group) onGroupSelected;
  final void Function(Entry, Group) onMoveEntry;
  final void Function(Group) onAddSubGroup;
  final void Function(Group) onAddEntryInGroup;
  final void Function(Group) onRenameGroup;
  final void Function(Group) onDeleteGroup;

  const _GroupTile({
    required this.treeEntry,
    required this.treeController,
    this.selectedGroup,
    required this.onGroupSelected,
    required this.onMoveEntry,
    required this.onAddSubGroup,
    required this.onAddEntryInGroup,
    required this.onRenameGroup,
    required this.onDeleteGroup,
  });

  @override
  State<_GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<_GroupTile> {
  bool _isHovered = false;

  void _onMenuItemSelected(String value, Group group) {
    switch (value) {
      case 'add_entry':
        widget.onAddEntryInGroup(group);
        break;
      case 'add_subgroup':
        widget.onAddSubGroup(group);
        break;
      case 'rename':
        widget.onRenameGroup(group);
        break;
      case 'delete':
        widget.onDeleteGroup(group);
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildContextMenuItems(BuildContext context, Group group) {
    final appLocalizations = AppLocalizations.of(context)!;
    return [
      PopupMenuItem(
        value: 'add_subgroup',
        child: Text(appLocalizations.addSubgroup),
      ),
      PopupMenuItem(
        value: 'add_entry',
        child: Text(appLocalizations.addNewEntryButton),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'rename',
        child: Text(appLocalizations.renameGroup),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Text(
          appLocalizations.deleteGroup,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    ];
  }

  void _showContextMenu(BuildContext context, Offset position, Group group) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: _buildContextMenuItems(context, group),
    ).then((value) {
      if (value != null) {
        _onMenuItemSelected(value, group);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final viewModel = context.watch<HomeViewModel>();
    final node = widget.treeEntry.node;
    final isSelected = widget.selectedGroup?.id == node.group.id;
    final theme = Theme.of(context);

    Color? backgroundColor;
    Color? foregroundColor;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primaryContainer;
      foregroundColor = theme.colorScheme.onPrimaryContainer;
    } else if (_isHovered) {
      backgroundColor = theme.colorScheme.primaryContainer.withOpacity(0.2);
    }

    return TreeIndentation(
      entry: widget.treeEntry,
      guide: IndentGuide.connectingLines(
        color: theme.dividerColor,
        thickness: 1,
        origin: 0.5,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onSecondaryTapUp: (details) => _showContextMenu(context, details.globalPosition, node.group),
          onTap: () => widget.onGroupSelected(node.group),
          child: DragTarget<Entry>(
            builder: (context, candidateData, rejectedData) {
              final isDragTarget = viewModel.dragTargetGroupId == node.group.id;
              return Container(
                margin: const EdgeInsets.fromLTRB(0, 2, 8, 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDragTarget ? theme.colorScheme.secondaryContainer : backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: widget.treeEntry.hasChildren
                          ? AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: widget.treeEntry.isExpanded ? 0.25 : 0,
                              child: IconButton(
                                iconSize: 16,
                                splashRadius: 16,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(FluentIcons.chevron_right_20_regular, color: foregroundColor),
                                onPressed: () => widget.treeController.toggleExpansion(node),
                              ),
                            )
                          : const SizedBox(width: 24),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      widget.treeEntry.isExpanded ? FluentIcons.folder_open_20_regular : FluentIcons.folder_20_regular,
                      size: 20,
                      color: foregroundColor ?? theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        node.group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(color: foregroundColor),
                      ),
                    ),
                  ],
                ),
              );
            },
            onWillAcceptWithDetails: (details) {
              if (details.data.groupId == node.group.id) return false;
              viewModel.setDragTargetGroup(node.group.id);
              return true;
            },
            onAcceptWithDetails: (details) {
              widget.onMoveEntry(details.data, node.group);
              viewModel.setDragTargetGroup(null);
            },
            onLeave: (details) => viewModel.setDragTargetGroup(null),
          ),
        ),
      ),
    );
  }
}