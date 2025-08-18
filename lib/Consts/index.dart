final class Consts {
  Consts._();

  /// Empty function constant
  static void doNothing() {}

  /// About network request
  static const request = (
  baseUrl: "http://192.168.48.23:8123/api",
  socketUrl: "http://192.168.48.23:8123",
  minWaitingTime: Duration(milliseconds: 500),
  cachedTime: Duration(milliseconds: 2000),
  sendTimeout: Duration(seconds: 5),
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  successCode: 0,
  pageSize: 10,
  );


}