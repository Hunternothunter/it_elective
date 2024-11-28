import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  final channel = WebSocketChannel.connect(Uri.parse('ws://your-websocket-url'));

  Stream<dynamic> getRealTimeHydroParameters() {
    return channel.stream;
  }

  void dispose() {
    channel.sink.close();
  }
}
