import 'package:signalr_netcore/signalr_client.dart';
import 'package:untitled/data/datasources/DTOs/ChatDTO.dart';
import 'package:flutter/foundation.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _hubConnection;

  final Map<String, Function(MessageDTO)> _messageListeners = {};

  Function(MessageDTO)? onMessageReceived;

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  void addMessageListener(String key, Function(MessageDTO) listener) {
    _messageListeners[key] = listener;
    debugPrint("SignalR: Added listener '$key'. Total listeners: ${_messageListeners.length}");
  }

  void removeMessageListener(String key) {
    _messageListeners.remove(key);
    debugPrint("SignalR: Removed listener '$key'. Total listeners: ${_messageListeners.length}");
  }

  Future<void> connect(String token) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      debugPrint("SignalR: Already connected, skipping...");
      return;
    }

    const serverUrl = "http://10.0.2.2:5090/chatHub";

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: HttpConnectionOptions(
      accessTokenFactory: () async => token,
    ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on("ReceiveMessage", _handleNewMessage);

    _hubConnection?.onclose(({error}) {
      debugPrint("SignalR: Connection closed. Error: $error");
    });

    _hubConnection?.onreconnecting(({error}) {
      debugPrint("SignalR: Reconnecting... Error: $error");
    });

    _hubConnection?.onreconnected(({connectionId}) {
      debugPrint("SignalR: Reconnected! ConnectionId: $connectionId");
    });

    try {
      await _hubConnection?.start();
      debugPrint("SignalR: Connected Successfully! State: ${_hubConnection?.state}");
    } catch (e) {
      debugPrint("SignalR: Connection Error: $e");
    }
  }

  void _handleNewMessage(List<Object?>? arguments) {
    debugPrint("SignalR: ReceiveMessage triggered! Args count: ${arguments?.length}");
    if (arguments != null && arguments.isNotEmpty) {
      try {
        final rawData = arguments[0];
        debugPrint("SignalR: rawData type: ${rawData.runtimeType}");

        Map<String, dynamic> data;
        if (rawData is Map<String, dynamic>) {
          data = rawData;
        } else if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        } else {
          debugPrint("SignalR: Unknown data type: ${rawData.runtimeType}");
          return;
        }

        final message = MessageDTO.fromJson(data);
        debugPrint("SignalR: MessageDTO created - id: ${message.id}, senderId: ${message.senderId}");

        // Gọi tất cả listeners đã đăng ký
        for (var entry in _messageListeners.entries) {
          debugPrint("SignalR: Notifying listener '${entry.key}'");
          entry.value(message);
        }

        // Backward compatibility
        if (onMessageReceived != null) {
          onMessageReceived!(message);
        }
      } catch (e, stackTrace) {
        debugPrint("SignalR: Error parsing incoming message: $e");
        debugPrint("SignalR: Stack trace: $stackTrace");
      }
    }
  }

  void disconnect() {
    _hubConnection?.stop();
    _hubConnection = null;
    debugPrint("SignalR: Disconnected");
  }
}
