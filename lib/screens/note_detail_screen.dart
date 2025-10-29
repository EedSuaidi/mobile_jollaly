import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';

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
    final updated = await context.read<NotesProvider>().update(
      id: _note!.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (updated != null) {
      setState(() => _note = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan disimpan')),
      );
    } else {
      final msg = context.read<NotesProvider>().error ?? 'Gagal menyimpan';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _confirmDelete() async {
    if (_note == null || _deleting) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _deleting = true);
    await context.read<NotesProvider>().remove(_note!.id);
    if (!mounted) return;
    setState(() => _deleting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note dihapus')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;
    if (note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Catatan')),
        body: const Center(child: Text('Data catatan tidak tersedia')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            tooltip: 'Simpan',
          ),
          IconButton(
            onPressed: (_saving || _deleting) ? null : _confirmDelete,
            icon: _deleting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
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
                  Text('Terakhir diperbarui: ${_formatDate(note)}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
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
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Konten wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Perubahan'),
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
