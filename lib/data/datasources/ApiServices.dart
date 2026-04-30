import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'http://10.0.2.2:5090';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    return _request(() => _dio.post(path, data: data));
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    return _request(() => _dio.put(path, data: data));
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    return _request(() => _dio.delete(path, data: data));
  }

  // ==========================================
  // 4. HÀM XỬ LÝ LỖI GỘP CHUNG (Rất quan trọng)
  // ==========================================
  Future<dynamic> _request(Future<Response> Function() requestFunc) async {
    try {
      final response = await requestFunc();
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw 'Kết nối mạng quá chậm, vui lòng thử lại.';
      } else if (e.type == DioExceptionType.connectionError) {
        throw 'Không có kết nối Internet.';
      } else if (e.response != null) {
        throw e.response?.data['message'] ?? 'Lỗi hệ thống: ${e.response?.statusCode}';
      } else {
        throw 'Đã xảy ra lỗi không xác định.';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}