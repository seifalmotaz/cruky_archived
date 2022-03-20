class FilePart {
  final String name;
  final String filename;
  final Stream<List<int>> bytes;
  FilePart(this.name, this.filename, this.bytes);
}
