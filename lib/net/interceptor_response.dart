import 'package:dio/dio.dart';
import '../model/result.dart';


final class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("Response -> $response");
    if (response.statusCode == 200) { // Http 状态码
      // 将 JSON Map 转换成实体模型对象
      final result = Result.fromJson(response.data);
      // 请求正常 & 业务正常
      if (result.success) {
        // 修改 Response 中的响应数据
        // 这样后续使用的数据就会是 Result 类型的
        response.data = result;
        response.statusMessage = result.message;
        return handler.resolve(response);
      }


      // 业务异常（请求是正常的，Result 的 code 不是正常码）
      // 此处是将所有业务码为非正常值的统一归置到异常一类中
      // 这样，我们就可以在统一的通过 catchError 的来捕获这些信息了
      return handler.reject(DioException(
        response: response,
        requestOptions: response.requestOptions,
        error: result,
        message: result.message,
      ));
    }
    super.onResponse(response, handler);
  }
}