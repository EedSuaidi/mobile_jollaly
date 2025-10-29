import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';

class CreateNoteScreen extends StatefulWidget {
  static const routeName = '/notes/create';
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final notes = context.read<NotesProvider>();
    final note = await notes.create(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (note != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note berhasil dibuat')),
      );
      Navigator.of(context).pop();
    } else {
      final msg = notes.error ?? 'Gagal membuat note';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Catatan')),
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
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      hintText: 'Masukkan judul catatan',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Konten',
                      hintText: 'Tulis isi catatan di sini...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 12,
                    minLines: 8,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Konten wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check),
                    label: const Text('Simpan'),
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
