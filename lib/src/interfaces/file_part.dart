/// files that in the request form
class FilePart {
  /// name of the field
  final String name;

  /// name of the file
  final String filename;

  /// streamed bytes of the files
  final Stream<List<int>> bytes;

  /// init
  FilePart(this.name, this.filename, this.bytes);
}
