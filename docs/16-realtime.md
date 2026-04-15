# 16 — Real-time (WebSockets, Chat, Online Status)

## Documentation
- [URLSessionWebSocketTask](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask)
- [Laravel Reverb](https://laravel.com/docs/reverb)
- [Laravel Broadcasting](https://laravel.com/docs/broadcasting)

---

## Laravel Reverb — Setup

```bash
composer require laravel/reverb
php artisan reverb:install
```

`.env`:
```
BROADCAST_CONNECTION=reverb

REVERB_APP_ID=myapp
REVERB_APP_KEY=myapp-key
REVERB_APP_SECRET=myapp-secret
REVERB_HOST=192.168.1.100    # machine IP, not localhost
REVERB_PORT=8080
REVERB_SCHEME=http
```

`docker-compose.yml`:
```yaml
reverb:
  command: php artisan reverb:start --host=0.0.0.0 --port=8080
  ports:
    - "8080:8080"
```

---

## Backend — Events & Channels

```php
// app/Events/MessageSent.php
class MessageSent implements ShouldBroadcast
{
    use Queueable;

    public function __construct(public Message $message) {}

    // Channel — private, only chat participants
    public function broadcastOn(): array
    {
        return [new PrivateChannel("chat.{$this->message->chat_id}")];
    }

    public function broadcastWith(): array
    {
        return ['message' => new MessageResource($this->message)];
    }
}

// routes/channels.php
Broadcast::channel('chat.{chatId}', function (User $user, int $chatId) {
    // Verify that the user is a participant in the chat
    return Chat::where('id', $chatId)
               ->where(fn($q) => $q->where('buyer_id', $user->id)
                                   ->orWhere('seller_id', $user->id))
               ->exists();
});

// Dispatching the event
broadcast(new MessageSent($message))->toOthers();
```

---

## iOS — WebSocket Client

```swift
import Foundation

@MainActor
final class WebSocketService: ObservableObject {
    static let shared = WebSocketService()

    private var tasks: [Int: URLSessionWebSocketTask] = [:]
    private let session = URLSession.shared

    // Subscribe to a chat channel
    func subscribeToChat(id: Int, onMessage: @escaping (Message) -> Void) {
        let url = URL(string: "ws://192.168.1.100:8080/app/myapp-key")!
        let task = session.webSocketTask(with: url)
        tasks[id] = task
        task.resume()

        // Authenticate the private channel
        Task { await authenticate(task: task, chatId: id) }

        // Listen for messages
        receive(task: task, chatId: id, onMessage: onMessage)
    }

    private func authenticate(task: URLSessionWebSocketTask, chatId: Int) async {
        guard let token = KeychainService.shared.getToken() else { return }

        // Subscribe to the private channel
        let subscribe: [String: Any] = [
            "event": "pusher:subscribe",
            "data": [
                "channel": "private-chat.\(chatId)",
                "auth": await fetchChannelAuth(chatId: chatId, token: token)
            ]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: subscribe),
           let str = String(data: data, encoding: .utf8) {
            try? await task.send(.string(str))
        }
    }

    private func receive(task: URLSessionWebSocketTask, chatId: Int, onMessage: @escaping (Message) -> Void) {
        task.receive { [weak self] result in
            switch result {
            case .success(let msg):
                if case .string(let str) = msg,
                   let data = str.data(using: .utf8),
                   let event = try? JSONDecoder.api.decode(WSEvent<Message>.self, from: data),
                   event.event == "App\\Events\\MessageSent" {
                    Task { @MainActor in onMessage(event.data) }
                }
                // Keep listening
                self?.receive(task: task, chatId: chatId, onMessage: onMessage)
            case .failure:
                // Reconnect after 3 seconds
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    self?.subscribeToChat(id: chatId, onMessage: onMessage)
                }
            }
        }
    }

    func unsubscribe(chatId: Int) {
        tasks[chatId]?.cancel()
        tasks.removeValue(forKey: chatId)
    }
}

struct WSEvent<T: Decodable>: Decodable {
    let event: String
    let data: T
}
```

### Usage in ChatViewModel

```swift
.onAppear {
    WebSocketService.shared.subscribeToChat(id: chat.id) { message in
        vm.messages.append(message)
    }
}
.onDisappear {
    WebSocketService.shared.unsubscribe(chatId: chat.id)
}
```

---

## Online Status

```php
// Broadcast presence channel
Broadcast::channel('presence-app', function (User $user) {
    return ['id' => $user->id, 'name' => $user->name];
});
```

```swift
// iOS — send a heartbeat every 30 seconds while the app is active
Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
    Task { try? await APIClient.shared.requestVoid(UserEndpoint.heartbeat) }
}
```
