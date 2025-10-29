import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class NotesProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  List<Note> _notes = [];
  bool _loading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchNotes() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notes = await _service.getNotes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Note?> create({required String title, required String content}) async {
    try {
      final note = await _service.createNote(title: title, content: content);
      _notes = [note, ..._notes];
      notifyListeners();
      return note;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<Note?> update({
    required String id,
    String? title,
    String? content,
  }) async {
    try {
      final updated = await _service.updateNote(
        id: id,
        title: title,
        content: content,
      );
      final idx = _notes.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notes[idx] = updated;
        notifyListeners();
      }
      return updated;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _service.deleteNote(id);
      _notes.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
