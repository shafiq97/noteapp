import 'package:flutter/material.dart';
import 'package:notes/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import '../auth_state_manager.dart';
import '../model/note/note.dart';
import '../model/note/notifier/main_list.dart';
import 'note_tile.dart';

class DismissibleNotes extends StatefulWidget {
  const DismissibleNotes({super.key});

  @override
  State<DismissibleNotes> createState() => _DismissibleNotesState();
}

class _DismissibleNotesState extends State<DismissibleNotes> {
  bool _showNotes = false; // flag to control visibility of private notes

  Future<bool> _authenticateUser() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;

    if (!canCheckBiometrics) {
      return false;
    }

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
      );
    } catch (e) {
      print(e);
    }

    if (authenticated) {
      Provider.of<AuthStateManager>(context, listen: false)
          .setAuthenticatedForPrivate(true);
    }

    return authenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder: (context, appTheme, child) =>
          Consumer2<NotesList, AuthStateManager>(
        builder: (context, noteslist, authState, child) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: GestureDetector(
                onVerticalDragUpdate: (details) async {
                  if (details.primaryDelta! < 0) {
                    bool authenticated = await _authenticateUser();
                    if (authenticated) {
                      setState(() {
                        _showNotes = true;
                      });
                    }
                  }
                },
                child: FlexibleSpaceBar(
                  title: Text('Your notes'),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  List<Note> filteredNotes = authState.isAuthenticatedForPrivate
                      ? noteslist.notes.where((note) => note.isPrivate).toList()
                      : noteslist.notes
                          .where((note) => !note.isPrivate)
                          .toList();

                  Note note = filteredNotes[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 6, bottom: 6, left: 12, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //     "Is Private: ${note.isPrivate}"), // Show isPrivate status
                        Dismissible(
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
                      ],
                    ),
                  );
                },
                childCount: authState.isAuthenticatedForPrivate
                    ? noteslist.notes
                        .where((note) => note.isPrivate)
                        .toList()
                        .length
                    : noteslist.notes
                        .where((note) => !note.isPrivate)
                        .toList()
                        .length,
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
