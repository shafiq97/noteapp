import 'package:flutter/material.dart';
import 'package:notes/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../model/note/note.dart';
import '../model/note/notifier/main_list.dart';
import 'note_tile.dart';

class DismissibleNotes extends StatefulWidget {
  const DismissibleNotes({super.key});

  @override
  State<DismissibleNotes> createState() => _DismissibleNotesState();
}

class _DismissibleNotesState extends State<DismissibleNotes> {
  bool _showNotes = false; // flag to control visibility

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder: (context, appTheme, child) => Consumer<NotesList>(
        builder: (context, noteslist, child) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 0) {
                    setState(() {
                      _showNotes = true;
                    });
                  }
                },
                child: FlexibleSpaceBar(
                  title: Text('Swipe down to reveal notes'),
                ),
              ),
            ),
            if (_showNotes)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Note note = noteslist.notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 6, bottom: 6, left: 12, right: 12),
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) =>
                            _onDismissDelete(direction, note.id),
                        background: Container(
                          color: Colors.transparent,
                        ),
                        secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.delete_rounded,
                              color: appTheme.theme.secondaryColor,
                            )),
                        child: NoteTile(note.id),
                      ),
                    );
                  },
                  childCount:
                      noteslist.notes.isEmpty ? 0 : noteslist.notes.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onDismissDelete(DismissDirection dir, int noteID) {
    var note = NotesList().getNoteWithID(noteID);
    NotesList().removeNote(noteID);
    SnackBar snack = SnackBar(
      content: const Text('Note deleted'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => NotesList().addNote(note),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
