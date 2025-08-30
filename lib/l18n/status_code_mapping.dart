
final class StatusCode {

  // 值是随便定义的，只要值不相同就可以随便定义
  // 不过最好是和 Http 状态码区分开
  static int UNKNOWN = 0;
  static int CANCEL_REQUEST = 1;
  static int DOMAIN_ERROR = 2;
  static int NETWORK_ERROR = 3;
  static int SEND_TIMEOUT = 4;
  static int CONNECTION_TIMEOUT = 5;
  static int RECEIVE_TIMEOUT = 6;
  static int BAD_CERTIFICATE = 7;


  /// 对应的 message 描述
  static const Map<int, String> messages = {
    0: "未知错误",
    1: "请求被取消",
    2: "域名解析失败",
    3: "网络连接失败",
    4: "发送超时",
    5: "连接超时",
    6: "接收超时",
    7: "证书错误",
  };

  /// 获取 message
  static String getMessage(int code) => messages[code] ?? "未知错误";

}