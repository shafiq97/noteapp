import 'note.dart';

class Plaintext extends Note {
  String content;

  bool isPrivate;

  Plaintext(id,
      {title = '', this.content = '', pinned = false, this.isPrivate = false})
      : super(id, title: title, pinned: pinned);

  Plaintext.fromJSON(Map<String, dynamic> json)
      : content = json['content'],
        isPrivate = json['isPrivate'] ??
            false, // assuming the key in JSON is 'isPrivate'
        super(json['id'] as int, title: json['title'], pinned: json['pinned']);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'plain': true,
        'title': title,
        'content': content,
        'pinned': pinned,
        'isPrivate': isPrivate
      };

  @override
  String toFormatted() => 'Title: $title\n\n$content';

  Plaintext modifyContent(String newContent) {
    return Plaintext(id, title: title, content: newContent);
  }

  Plaintext modifyTitle(String newTitle) {
    return Plaintext(id, title: newTitle, content: content);
  }

  bool isChecklist() => false;
}
