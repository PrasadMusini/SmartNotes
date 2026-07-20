import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_snackbar.dart';
import '../../application/notes_providers.dart';
import '../../domain/entities/note.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({this.note, super.key});

  final Note? note;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final notifier = ref.read(notesNotifierProvider.notifier);

    if (_isEditing) {
      final updated = await notifier.updateNote(
        widget.note!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      if (updated != null) {
        AppSnackbar.showTop('Note updated');
        Navigator.of(context).pop(updated);
      }
      return;
    }

    final created = await notifier.createNote(
      title: _titleController.text,
      content: _contentController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (created != null) {
      AppSnackbar.showTop('Note created');
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(hintText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please add a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contentController,
                maxLines: 18,
                minLines: 10,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please add some content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
