import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'graphql_service.g.dart';

@RestApi()
abstract class GraphqlService {
  factory GraphqlService(Dio dio) = _GraphqlService;

  @POST("/graphql")
  Future<String> post(@Body() String payload);
}
