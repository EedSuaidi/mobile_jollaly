import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import 'auth_service.dart';

class NoteService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _headers(String? token) => {
    HttpHeaders.contentTypeHeader: 'application/json',
    if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
  };

  Future<List<Note>> getNotes({bool? isFavorite, bool? isArchived}) async {
    final token = await _getToken();
    final uri = Uri.parse('${AuthService.apiBase}/notes').replace(
      queryParameters: {
        if (isFavorite != null) 'isFavorite': isFavorite.toString(),
        if (isArchived != null) 'isArchived': isArchived.toString(),
      },
    );
    final resp = await http.get(uri, headers: _headers(token));
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && decoded['success'] == true) {
      final list = (decoded['data'] as List)
          .cast<Map<String, dynamic>>()
          .map(Note.fromJson)
          .toList();
      return list;
    }
    throw Exception(decoded['message'] ?? 'Failed to fetch notes');
  }

  Future<Note> getNote(String id) async {
    final token = await _getToken();
    final url = Uri.parse('${AuthService.apiBase}/notes/$id');
    final resp = await http.get(url, headers: _headers(token));
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && decoded['success'] == true) {
      return Note.fromJson(decoded['data'] as Map<String, dynamic>);
    }
    throw Exception(decoded['message'] ?? 'Failed to fetch note');
  }

  Future<Note> createNote({
    required String title,
    required String content,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${AuthService.apiBase}/notes');
    final resp = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({'title': title, 'content': content}),
    );
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && decoded['success'] == true) {
      return Note.fromJson(decoded['data'] as Map<String, dynamic>);
    }
    throw Exception(decoded['message'] ?? 'Failed to create note');
  }

  Future<Note> updateNote({
    required String id,
    String? title,
    String? content,
    bool? isFavorite,
    bool? isArchived,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${AuthService.apiBase}/notes/$id');
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;
    if (isFavorite != null) body['isFavorite'] = isFavorite;
    if (isArchived != null) body['isArchived'] = isArchived;
    final resp = await http.put(
      url,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && decoded['success'] == true) {
      return Note.fromJson(decoded['data'] as Map<String, dynamic>);
    }
    throw Exception(decoded['message'] ?? 'Failed to update note');
  }

  Future<void> deleteNote(String id) async {
    final token = await _getToken();
    final url = Uri.parse('${AuthService.apiBase}/notes/$id');
    final resp = await http.delete(url, headers: _headers(token));
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && decoded['success'] == true) {
      return;
    }
    throw Exception(decoded['message'] ?? 'Failed to delete note');
  }

  Future<Note> toggleFavorite(Note note) async {
    return updateNote(id: note.id, isFavorite: !note.isFavorite);
  }

  Future<Note> toggleArchived(Note note) async {
    return updateNote(id: note.id, isArchived: !note.isArchived);
  }
}
