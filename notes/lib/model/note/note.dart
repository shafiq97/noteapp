abstract class Note {
  final int id;
  String title;
  bool pinned;
  bool isPrivate; // Add this line

  Note(this.id,
      {this.title = '',
      this.pinned = false,
      this.isPrivate = false}); // Modify this line

  Map<String, dynamic> toJson();
  String toFormatted();
}
