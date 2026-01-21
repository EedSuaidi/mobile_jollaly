import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';
import '../providers/settings_provider.dart';

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
  
  // 1. State tambahan buat deteksi perubahan biar fitur "Anti-Kepleset" jalan
  bool _isFormChanged = false;

  @override
  void initState() {
    super.initState();
    // 2. Pasang pendengar (listener) buat tau kalau user mulai ngetik
    _titleCtrl.addListener(_onFormChange);
    _contentCtrl.addListener(_onFormChange);
  }

  void _onFormChange() {
    final hasContent = _titleCtrl.text.isNotEmpty || _contentCtrl.text.isNotEmpty;
    // Cuma update UI kalau status berubah (biar hemat resource)
    if (_isFormChanged != hasContent) {
      setState(() {
        _isFormChanged = hasContent;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFormChange); // Bersihin listener
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // 3. Fitur Reset Form (Bersihin Layar)
  void _resetForm() {
    _titleCtrl.clear();
    _contentCtrl.clear();
    setState(() {
      _isFormChanged = false;
    });
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
      // Set false biar nggak dicegat PopScope pas sukses simpan
      _isFormChanged = false; 
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note berhasil dibuat')));
      Navigator.of(context).pop();
    } else {
      final msg = notes.error ?? 'Gagal membuat note';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // 4. Logic Dialog Konfirmasi Keluar
  Future<bool> _onWillPop() async {
    // Kalau form kosong atau lagi loading, bolehin keluar langsung
    if (!_isFormChanged || _submitting) return true;

    final settings = context.read<SettingsProvider>();
    final isId = settings.locale.languageCode == 'id';

    // Munculin Dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isId ? 'Buang Perubahan?' : 'Discard Changes?'),
        content: Text(isId 
          ? 'Kamu punya tulisan yang belum disimpan. Yakin mau keluar?' 
          : 'You have unsaved changes. Are you sure you want to leave?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // Jangan keluar
            child: Text(isId ? 'Batal' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true), // Iya, keluar aja
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isId ? 'Keluar' : 'Leave'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isId = settings.locale.languageCode == 'id';
    
    // 5. Bungkus Scaffold pake PopScope (Pengganti WillPopScope di Flutter baru)
    return PopScope(
      canPop: false, // Default kita block, kita handle manual di onPopInvoked
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isId ? 'Buat Catatan' : 'Create Note'),
          actions: [
            // Tombol Reset (Muncul cuma kalau ada isinya)
            if (_isFormChanged)
              IconButton(
                tooltip: isId ? 'Reset Form' : 'Reset Form',
                icon: const Icon(Icons.refresh),
                onPressed: _resetForm,
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
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: isId ? 'Judul' : 'Title',
                        hintText: isId
                            ? 'Masukkan judul catatan'
                            : 'Enter note title',
                        // 6. Fitur counter visual sederhana
                        suffixText: '${_titleCtrl.text.length} chars', 
                      ),
                      onChanged: (v) => setState(() {}), // Update counter realtime
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? (isId ? 'Judul wajib diisi' : 'Title is required')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentCtrl,
                      decoration: InputDecoration(
                        labelText: isId ? 'Konten' : 'Content',
                        hintText: isId
                            ? 'Tulis isi catatan di sini...'
                            : 'Write your note here...',
                        alignLabelWithHint: true,
                        // Counter karakter juga di sini
                        counterText: '${_contentCtrl.text.length} characters',
                      ),
                      maxLines: 12,
                      minLines: 8,
                      onChanged: (v) => setState(() {}), // Update counter
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? (isId ? 'Konten wajib diisi' : 'Content is required')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(isId ? 'Simpan' : 'Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}