import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ServeHandler {

  Handler get handler {

    final _router = Router();
    return _router; 

    _router.get('/', (Request request) {
      return Response.ok('primeira rota\n');
    });

  return _router;
  }
}