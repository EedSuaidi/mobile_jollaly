import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class NotesProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  List<Note> _notes = [];
  bool _loading = false;
  String? _error;
  bool? _filterFavorite;
  bool? _filterArchived = false; // default: show non-archived notes

  List<Note> get notes => _notes;
  bool get isLoading => _loading;
  String? get error => _error;
  bool? get filterFavorite => _filterFavorite;
  bool? get filterArchived => _filterArchived;

  Future<void> fetchNotes({bool? isFavorite, bool? isArchived}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final archivedFlag = (isArchived ?? _filterArchived ?? false);
      _notes = await _service.getNotes(
        isFavorite: isFavorite ?? _filterFavorite,
        isArchived: archivedFlag,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setFilters({bool? isFavorite, bool? isArchived}) {
    _filterFavorite = isFavorite;
    _filterArchived = isArchived ?? false; // default to not archived on main
    fetchNotes();
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
    bool? isFavorite,
    bool? isArchived,
  }) async {
    try {
      final updated = await _service.updateNote(
        id: id,
        title: title,
        content: content,
        isFavorite: isFavorite,
        isArchived: isArchived,
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

  Future<void> toggleFavorite(Note note) async {
    final updated = await _service.toggleFavorite(note);
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> toggleArchived(Note note) async {
    final updated = await _service.toggleArchived(note);
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> bulkArchive(List<String> ids, {required bool archived}) async {
    try {
      for (final id in ids) {
        await _service.updateNote(id: id, isArchived: archived);
        final idx = _notes.indexWhere((n) => n.id == id);
        if (idx != -1) {
          _notes[idx].isArchived = archived;
        }
      }
      // If archiving while archive filter is inactive, remove archived notes from current view
      if (archived && (_filterArchived != true)) {
        _notes.removeWhere((n) => ids.contains(n.id));
      }
      notifyListeners();
      // Ensure consistency by refetching with current filters
      await fetchNotes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> bulkDelete(List<String> ids) async {
    try {
      for (final id in ids) {
        await _service.deleteNote(id);
      }
      _notes.removeWhere((n) => ids.contains(n.id));
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
