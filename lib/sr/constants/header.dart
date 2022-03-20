class ReqHeader {
  final String contentType;
  const ReqHeader(this.contentType);

  static String jsonType = 'application/json';
  static String htmlType = 'text/html';
  static String plainType = 'text/plain';
}
