import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
=======
import 'package:google_fonts/google_fonts.dart';
>>>>>>> add-font

import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/settings_provider.dart';
import '../models/note.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    Future.microtask(() => context.read<NotesProvider>().fetchNotes());
=======
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().fetchNotes();
    });
>>>>>>> add-font
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(Note n) {
    final dt = n.updatedAt ?? n.createdAt;
    if (dt == null) return '';
    return DateFormat(
      'dd MMMM',
      Localizations.localeOf(context).languageCode,
    ).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final notesProv = context.watch<NotesProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notes = notesProv.notes;
    final filtered = _query.isEmpty
        ? notes
        : notes
              .where(
                (n) => (n.title).toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: _selected.isEmpty
            ? const SizedBox.shrink()
            : Text('${_selected.length} dipilih'),
        actions: [
          if (_selected.isNotEmpty) ...[
            IconButton(
              tooltip: () {
                final idLang = settings.locale.languageCode == 'id';
                final isArchiveActive =
                    context.read<NotesProvider>().filterArchived == true;
                return isArchiveActive
                    ? (idLang ? 'Batalkan Arsip' : 'Unarchive')
                    : (idLang ? 'Arsipkan' : 'Archive');
              }(),
              icon: const Icon(Icons.archive_outlined),
              onPressed: () async {
                final ids = _selected.toList();
                final isArchiveActive =
                    context.read<NotesProvider>().filterArchived == true;
                await context.read<NotesProvider>().bulkArchive(
                  ids,
                  archived: !isArchiveActive,
                );
                setState(() => _selected.clear());
              },
            ),
            IconButton(
              tooltip: settings.locale.languageCode == 'id'
                  ? 'Hapus'
                  : 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ids = _selected.toList();
                await context.read<NotesProvider>().bulkDelete(ids);
                setState(() => _selected.clear());
              },
            ),
          ],
          IconButton(
            tooltip: settings.locale.languageCode == 'id'
                ? 'Ubah bahasa'
                : 'Change language',
            icon: const Icon(Icons.g_translate),
            onPressed: () {
              final next = settings.locale.languageCode == 'id'
                  ? const Locale('en')
                  : const Locale('id');
              context.read<SettingsProvider>().setLocale(next);
            },
          ),
          IconButton(
            tooltip: settings.themeMode == ThemeMode.light ? 'Gelap' : 'Terang',
            icon: Icon(
              settings.themeMode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<SettingsProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out')));
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(CreateNoteScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<NotesProvider>().fetchNotes(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  settings.locale.languageCode == 'id' ? 'Catatan' : 'Notes',
<<<<<<< HEAD
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
=======
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
>>>>>>> add-font
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: settings.locale.languageCode == 'id'
                        ? 'Cari'
                        : 'Search',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FilterButton(
                        label: settings.locale.languageCode == 'id'
                            ? 'Favorit'
                            : 'Favorite',
                        active:
                            notesProv.filterFavorite == true &&
                            notesProv.filterArchived != true,
                        color: const Color(0xFFF5C74C),
                        icon: Icons.star_border_rounded,
                        onTap: () {
                          final isActive =
                              notesProv.filterFavorite == true &&
                              notesProv.filterArchived != true;
                          context.read<NotesProvider>().setFilters(
                            isFavorite: isActive ? null : true,
                            isArchived: isActive ? null : false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FilterButton(
                        label: settings.locale.languageCode == 'id'
                            ? 'Arsip'
                            : 'Archive',
                        active: notesProv.filterArchived == true,
                        color: Colors.grey.shade400,
                        icon: Icons.archive_outlined,
                        onTap: () {
                          final isActive = notesProv.filterArchived == true;
                          context.read<NotesProvider>().setFilters(
                            isFavorite: null,
                            isArchived: isActive ? null : true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  settings.locale.languageCode == 'id'
                      ? 'Catatan Terbaru'
                      : 'Latest Notes',
<<<<<<< HEAD
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
=======
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
>>>>>>> add-font
                ),
                const SizedBox(height: 12),
                if (notesProv.isLoading && notesProv.notes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if ((notesProv.error ?? '').isNotEmpty &&
                    notesProv.notes.isEmpty)
                  Center(child: Text(notesProv.error!))
                else if (notesProv.notes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      settings.locale.languageCode == 'id'
                          ? 'Belum ada catatan. Klik + untuk menambah.'
                          : 'No notes yet. Tap + to add.',
                    ),
                  )
                else ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = 2;
                      const spacing = 16.0;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(4),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 0.86,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final note = filtered[index];
                          return _NoteCard(
                            note: note,
                            dateText: _formatDate(note),
                            onTap: () async {
                              await Navigator.of(context).pushNamed(
                                NoteDetailScreen.routeName,
                                arguments: note,
                              );
                            },
                            onToggleFavorite: () async {
                              await context
                                  .read<NotesProvider>()
                                  .toggleFavorite(note);
                            },
                            onSelect: () {
                              setState(() {
                                if (_selected.contains(note.id)) {
                                  _selected.remove(note.id);
                                } else {
                                  _selected.add(note.id);
                                }
                              });
                            },
                            isSelected: _selected.contains(note.id),
                          );
                        },
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _FilterButton({
    required this.label,
    required this.active,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: active ? Colors.white : Colors.black87,
    );
    final iconColor = active ? Colors.white : Colors.grey.shade700;
    final avatarBg = active
        ? Colors.white.withOpacity(0.2)
=======
    final textStyle = GoogleFonts.montserrat(
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: active ? Colors.white : Colors.black87,
      ),
    );
    final iconColor = active ? Colors.white : Colors.grey.shade700;
    final avatarBg = active
        ? Colors.white.withAlpha((0.2 * 255).round())
>>>>>>> add-font
        : Colors.grey.shade300;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
<<<<<<< HEAD
              color: Colors.black.withOpacity(0.04),
=======
              color: Colors.black.withAlpha((0.04 * 255).round()),
>>>>>>> add-font
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: avatarBg,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final String dateText;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onSelect;
  final bool isSelected;
  const _NoteCard({
    required this.note,
    required this.dateText,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onSelect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseCardColor = isDark ? Colors.grey.shade800 : Colors.white;
    final selectedColor = isDark ? Colors.blue.shade900 : Colors.blue.shade100;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isSelected ? selectedColor : baseCardColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty
                    ? (Localizations.localeOf(context).languageCode == 'id'
                          ? 'Catatanku'
                          : 'My Note')
                    : note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
<<<<<<< HEAD
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : null,
=======
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : null,
                  ),
>>>>>>> add-font
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
<<<<<<< HEAD
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : null,
=======
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : null,
                    ),
>>>>>>> add-font
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Divider(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                thickness: 1,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateText,
<<<<<<< HEAD
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : null,
=======
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: isDark ? Colors.white70 : null),
>>>>>>> add-font
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      note.isFavorite ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF5C74C),
                    ),
                    tooltip:
                        Localizations.localeOf(context).languageCode == 'id'
                        ? 'Favorit'
                        : 'Favorite',
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
