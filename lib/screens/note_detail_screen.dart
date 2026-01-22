import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/settings_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  static const routeName = '/notes/detail';
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _saving = false;
  bool _deleting = false;
  Note? _note;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _contentCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (_note == null && arg is Note) {
      _note = arg;
      _titleCtrl.text = _note!.title;
      _contentCtrl.text = _note!.content;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String _formatDate(Note n) {
    final dt = n.updatedAt ?? n.createdAt;
    if (dt == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _note == null) return;
    setState(() => _saving = true);
    final notesProv = context.read<NotesProvider>();
    final settingsProv = context.read<SettingsProvider>();
    final updated = await notesProv.update(
      id: _note!.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (updated != null) {
      setState(() => _note = updated);
      final isId = settingsProv.locale.languageCode == 'id';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isId ? 'Perubahan disimpan' : 'Changes saved')),
      );
    } else {
      final isId = settingsProv.locale.languageCode == 'id';
      final fallback = isId ? 'Gagal menyimpan' : 'Failed to save';
      final msg = notesProv.error ?? fallback;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _confirmDelete() async {
    if (_note == null || _deleting) return;
    final isId = context.read<SettingsProvider>().locale.languageCode == 'id';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isId ? 'Hapus Catatan' : 'Delete Note'),
        content: Text(
          isId
              ? 'Anda yakin ingin menghapus catatan ini?'
              : 'Are you sure you want to delete this note?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isId ? 'Batal' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isId ? 'Hapus' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _deleting = true);
    await context.read<NotesProvider>().remove(_note!.id);
    if (!mounted) return;
    setState(() => _deleting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isId ? 'Note dihapus' : 'Note deleted')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isId = settings.locale.languageCode == 'id';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final note = _note;
    if (note == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isId ? 'Detail Catatan' : 'Note Detail'),
          actions: [
            IconButton(
              tooltip: isId ? 'Ubah bahasa' : 'Change language',
              icon: const Icon(Icons.g_translate),
              onPressed: () {
                final next = isId ? const Locale('en') : const Locale('id');
                context.read<SettingsProvider>().setLocale(next);
              },
            ),
            IconButton(
              tooltip: settings.themeMode == ThemeMode.light
                  ? 'Gelap'
                  : 'Terang',
              icon: Icon(
                settings.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => context.read<SettingsProvider>().toggleTheme(),
            ),
          ],
        ),
        body: Center(
          child: Text(
            isId ? 'Data catatan tidak tersedia' : 'Note data not available',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Detail Catatan' : 'Note Detail'),
        actions: [
          IconButton(
            onPressed: (_saving || _deleting) ? null : _confirmDelete,
            icon: _deleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            tooltip: isId ? 'Hapus' : 'Delete',
          ),
          IconButton(
            tooltip: isId ? 'Ubah bahasa' : 'Change language',
            icon: const Icon(Icons.g_translate),
            onPressed: () {
              final next = isId ? const Locale('en') : const Locale('id');
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${isId ? 'Terakhir diperbarui' : 'Last updated'}: ${_formatDate(note)}',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: isDark ? Colors.white70 : null),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: isId ? 'Judul' : 'Title',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? (isId ? 'Judul wajib diisi' : 'Title is required')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Konten',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 14,
                    minLines: 8,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? (isId ? 'Konten wajib diisi' : 'Content is required')
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(isId ? 'Simpan Perubahan' : 'Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
