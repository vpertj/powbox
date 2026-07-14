import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwbox/core/models/entry.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:pwbox/core/models/group.dart';
import 'package:pwbox/core/services/favicon_service.dart';
import 'package:pwbox/core/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:pwbox/features/home/home_view_model.dart';

const double kBorderRadiusMedium = 12.0;
const double kBorderRadiusSmall = 8.0;

class EntryListView extends StatefulWidget {
  final List<Entry> entries;
  final List<Group> groups;
  final bool isSearchActive;
  final Function(Entry) onEdit;
  final Function(Entry) onDelete;
  final VoidCallback onAddEntry;
  final VoidCallback onClearSearch;
  final Set<String> animatingDeletedEntryIds;
  final Group? selectedGroup;
  final void Function(Entry, Group) onMoveEntry;

  const EntryListView({
    super.key,
    required this.entries,
    required this.groups,
    required this.isSearchActive,
    required this.onEdit,
    required this.onDelete,
    required this.animatingDeletedEntryIds,
    required this.onAddEntry,
    required this.onClearSearch,
    required this.selectedGroup,
    required this.onMoveEntry,
  });

  @override
  State<EntryListView> createState() => _EntryListViewState();
}

class _EntryListViewState extends State<EntryListView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    if (widget.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isSearchActive ? Icons.search_off : Icons.folder_open,
              size: 64.0,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: kPaddingMedium),
            Text(
              widget.isSearchActive
                  ? AppLocalizations.of(context)!.noSearchResults
                  : AppLocalizations.of(context)!.emptyGroup,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return viewModel.isGridView ? _buildGridView(viewModel) : _buildListView(viewModel);
  }

  Widget _buildListView(HomeViewModel viewModel) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium, vertical: kPaddingSmall),
      itemCount: widget.entries.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 56, endIndent: 16),
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
        final isAnimatingDelete = widget.animatingDeletedEntryIds.contains(entry.id);
        final isSelected = viewModel.selectedEntry?.id == entry.id;

        return AnimatedOpacity(
          opacity: isAnimatingDelete ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              height: isAnimatingDelete ? 0.0 : null,
              child: _EntryTile(
                entry: entry,
                groups: widget.groups,
                isSearchActive: widget.isSearchActive,
                isSelected: isSelected,
                onEdit: widget.onEdit,
                onDelete: widget.onDelete,
                viewModel: viewModel,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(HomeViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.all(kPaddingMedium),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        childAspectRatio: 1.0,
        crossAxisSpacing: kPaddingMedium,
        mainAxisSpacing: kPaddingMedium,
      ),
      itemCount: widget.entries.length,
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
        final isAnimatingDelete = widget.animatingDeletedEntryIds.contains(entry.id);
        final isSelected = viewModel.selectedEntry?.id == entry.id;

        return AnimatedOpacity(
          opacity: isAnimatingDelete ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              height: isAnimatingDelete ? 0.0 : null,
              child: _EntryGridTile(
                entry: entry,
                groups: widget.groups,
                isSearchActive: widget.isSearchActive,
                isSelected: isSelected,
                onEdit: widget.onEdit,
                onDelete: widget.onDelete,
                viewModel: viewModel,
                onMoveEntry: widget.onMoveEntry,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EntryTile extends StatefulWidget {
  final Entry entry;
  final List<Group> groups;
  final bool isSearchActive;
  final bool isSelected;
  final Function(Entry) onEdit;
  final Function(Entry) onDelete;
  final HomeViewModel viewModel;

  const _EntryTile({
    required this.entry,
    required this.groups,
    required this.isSearchActive,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    required this.viewModel,
  });

  @override
  State<_EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<_EntryTile> {
  Future<Uint8List?>? _faviconFuture;
  bool _isHovered = false;
  bool _justCopiedUsername = false;
  bool _justCopiedPassword = false;

  @override
  void initState() {
    super.initState();
    _faviconFuture = FaviconService().getFavicon(widget.entry.url);
  }

  void _copyToClipboard(BuildContext context, String text, String type) {
    final appLocalizations = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));

    if (type == 'Username') {
      setState(() => _justCopiedUsername = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justCopiedUsername = false);
      });
    } else {
      setState(() => _justCopiedPassword = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justCopiedPassword = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final group = widget.groups.firstWhere(
      (g) => g.id == widget.entry.groupId,
      orElse: () => Group(id: '', name: appLocalizations.groupNotFound),
    );

    final Color avatarColor = Colors.primaries[widget.entry.title.hashCode % Colors.primaries.length];
    final Color? backgroundColor = widget.isSelected
        ? theme.colorScheme.primaryContainer.withOpacity(0.4)
        : _isHovered
            ? theme.colorScheme.onSurface.withOpacity(0.05)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          widget.viewModel.selectEntry(widget.entry);
          widget.onEdit(widget.entry);
        },
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                  child: FutureBuilder<Uint8List?>(
                    future: _faviconFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                        return Image.memory(snapshot.data!, fit: BoxFit.contain);
                      } else {
                        return CircleAvatar(
                          backgroundColor: avatarColor.withOpacity(0.8),
                          child: Text(
                            widget.entry.title.isNotEmpty ? widget.entry.title.substring(0, 1).toUpperCase() : ' ',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isSearchActive ? '${widget.entry.username}  •  ${group.name}' : widget.entry.username,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (_isHovered || widget.isSelected)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: _justCopiedUsername
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.copy_all_outlined, size: 20),
                      tooltip: appLocalizations.copyUsernameTooltip,
                      onPressed: () => _copyToClipboard(context, widget.entry.username, 'Username'),
                    ),
                    IconButton(
                      icon: _justCopiedPassword
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.password_outlined, size: 20),
                      tooltip: appLocalizations.copyPasswordTooltip,
                      onPressed: () => _copyToClipboard(context, widget.entry.password, 'Password'),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_outlined, size: 20),
                      tooltip: 'More',
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit(widget.entry);
                        } else if (value == 'delete') {
                          widget.onDelete(widget.entry);
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(appLocalizations.editButton),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(appLocalizations.deleteButton, style: TextStyle(color: theme.colorScheme.error)),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryGridTile extends StatefulWidget {
  final Entry entry;
  final List<Group> groups;
  final bool isSearchActive;
  final bool isSelected;
  final Function(Entry) onEdit;
  final Function(Entry) onDelete;
  final HomeViewModel viewModel;
  final void Function(Entry, Group) onMoveEntry;

  const _EntryGridTile({
    required this.entry,
    required this.groups,
    required this.isSearchActive,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    required this.viewModel,
    required this.onMoveEntry,
  });

  @override
  State<_EntryGridTile> createState() => _EntryGridTileState();
}

class _EntryGridTileState extends State<_EntryGridTile> {
  bool _isHovered = false;

  void _copyToClipboard(BuildContext context, String text, String type) {
    final appLocalizations = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == 'Username'
              ? appLocalizations.usernameCopied
              : appLocalizations.passwordCopied,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'copy_username':
        _copyToClipboard(context, widget.entry.username, 'Username');
        break;
      case 'copy_password':
        _copyToClipboard(context, widget.entry.password, 'Password');
        break;
      case 'edit':
        widget.onEdit(widget.entry);
        break;
      case 'delete':
        widget.onDelete(widget.entry);
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildContextMenuItems(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return [
      PopupMenuItem(
        value: 'copy_username',
        child: Text(appLocalizations.copyUsernameTooltip),
      ),
      PopupMenuItem(
        value: 'copy_password',
        child: Text(appLocalizations.copyPasswordTooltip),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'edit',
        child: Text(appLocalizations.editButton),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Text(
          appLocalizations.deleteButton,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    ];
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: _buildContextMenuItems(context),
    ).then((value) {
      if (value != null) {
        _onMenuItemSelected(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final group = widget.groups.firstWhere(
      (g) => g.id == widget.entry.groupId,
      orElse: () => Group(id: '', name: appLocalizations.groupNotFound),
    );

    final Color avatarColor = Colors.primaries[widget.entry.title.hashCode % Colors.primaries.length];

    return DragTarget<Entry>(
      onAcceptWithDetails: (details) {
        final draggedEntry = details.data;
        if (draggedEntry.id != widget.entry.id) {
          widget.viewModel.reorderEntry(draggedEntry, widget.entry);
        }
      },
      onWillAcceptWithDetails: (details) {
        widget.viewModel.setDragTargetGroup(widget.entry.groupId);
        return true;
      },
      onLeave: (details) {
        widget.viewModel.setDragTargetGroup(null);
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<Entry>(
          data: widget.entry,
          feedback: Opacity(
            opacity: 0.7,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                width: 150,
                height: 150,
                child: _EntryGridTile(
                  entry: widget.entry,
                  groups: widget.groups,
                  isSearchActive: widget.isSearchActive,
                  isSelected: widget.isSelected,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  viewModel: widget.viewModel,
                  onMoveEntry: widget.onMoveEntry,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: _EntryGridTile(
              entry: widget.entry,
              groups: widget.groups,
              isSearchActive: widget.isSearchActive,
              isSelected: widget.isSelected,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              viewModel: widget.viewModel,
              onMoveEntry: widget.onMoveEntry,
            ),
          ),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedScale(
              scale: _isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Card(
                elevation: _isHovered || widget.isSelected ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                  side: widget.isSelected
                      ? BorderSide(color: theme.colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: GestureDetector(
                  onSecondaryTapUp: (details) => _showContextMenu(context, details.globalPosition),
                  child: InkWell(
                    onTap: () {
                      widget.viewModel.selectEntry(widget.entry);
                      widget.onEdit(widget.entry);
                    },
                    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                            child: FutureBuilder<Uint8List?>(
                              future: FaviconService().getFavicon(widget.entry.url),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                                  return CircleAvatar(
                                    backgroundImage: MemoryImage(snapshot.data!),
                                    backgroundColor: Colors.transparent,
                                  );
                                } else {
                                  return CircleAvatar(
                                    backgroundColor: avatarColor.withOpacity(0.8),
                                    child: Text(
                                      widget.entry.title.isNotEmpty ? widget.entry.title.substring(0, 1).toUpperCase() : ' ',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.entry.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isSearchActive ? '${widget.entry.username}  •  ${group.name}' : widget.entry.username,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}