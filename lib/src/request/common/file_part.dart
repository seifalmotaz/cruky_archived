library cruky.request.file_part;

/// presenting file data and bytes stream
class FilePart {
  /// name of the field
  final String name;

  /// name of the file
  final String filename;

  /// streamed bytes of the files
  final Stream<List<int>> bytes;

  /// presenting file data and bytes stream
  FilePart(this.name, this.filename, this.bytes);
}
