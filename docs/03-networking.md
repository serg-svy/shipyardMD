# 03 — Networking

## Documentation
- [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Codable](https://developer.apple.com/documentation/swift/codable)

---

## Endpoint Protocol

```swift
enum HTTPMethod: String { case GET, POST, PUT, PATCH, DELETE }

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var multipart: MultipartData? { get }
    var requiresAuth: Bool { get }
}
```

---

## APIClient Protocol — required for testability

```swift
// The protocol allows replacing APIClient with a mock in tests
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
    func requestVoid(_ endpoint: any Endpoint) async throws
}
```

## APIClient — implementation

```swift
final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? ""
    // IMPORTANT: token from Keychain, not UserDefaults — see 12-security.md
    private var token: String? { KeychainService.shared.getToken() }

    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + endpoint.path)!
        urlComponents.queryItems = endpoint.queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = endpoint.method.rawValue

        if endpoint.requiresAuth, let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let multipart = endpoint.multipart {
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = multipart.encode(boundary: boundary)
        } else if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode

        guard (200..<300).contains(statusCode) else {
            throw APIError.httpError(statusCode, data)
        }

        return try JSONDecoder.api.decode(T.self, from: data)
    }
}

extension JSONDecoder {
    static let api: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
```

---

## Multipart Form Data

Used for uploading photos along with form fields.

```swift
struct MultipartData {
    var fields: [String: String]
    var files: [MultipartFile]

    func encode(boundary: String) -> Data {
        var data = Data()
        let crlf = "\r\n"
        let prefix = "--\(boundary)\(crlf)"

        for (key, value) in fields {
            data += prefix.data(using: .utf8)!
            data += "Content-Disposition: form-data; name=\"\(key)\"\(crlf)\(crlf)".data(using: .utf8)!
            data += value.data(using: .utf8)!
            data += crlf.data(using: .utf8)!
        }

        for file in files {
            data += prefix.data(using: .utf8)!
            data += "Content-Disposition: form-data; name=\"\(file.field)\"; filename=\"\(file.filename)\"\(crlf)".data(using: .utf8)!
            data += "Content-Type: \(file.mimeType)\(crlf)\(crlf)".data(using: .utf8)!
            data += file.data
            data += crlf.data(using: .utf8)!
        }

        data += "--\(boundary)--\(crlf)".data(using: .utf8)!
        return data
    }
}

struct MultipartFile {
    let field: String
    let data: Data
    let filename: String
    let mimeType: String
}
```

---

## Models — important pitfalls

### Always make status fields optional

```swift
// WRONG — will crash if backend returns null
struct Listing: Decodable {
    let status: String
    let viewsCount: Int
}

// CORRECT
struct Listing: Decodable {
    let status: String?        // can be null for new records
    let viewsCount: Int?
}
```

### CodingKeys vs snakeCase

It's better to use `.convertFromSnakeCase` in the decoder than to write `CodingKeys` manually:

```swift
// Automatically: views_count → viewsCount, cover_url → coverUrl
JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase
```

### Paginated Response

```swift
struct Paginated<T: Decodable>: Decodable {
    let data: [T]
    let meta: PaginationMeta?
}

struct PaginationMeta: Decodable {
    let currentPage: Int
    let lastPage: Int
    let total: Int
}
```

---

## Laravel Sanctum — Bearer Token

```swift
// Save after login
UserDefaults.standard.set(token, forKey: "auth_token")

// Remove on logout
UserDefaults.standard.removeObject(forKey: "auth_token")
```

On the backend in `config/sanctum.php`:
```php
'expiration' => 60 * 24 * 30, // 30 days
```

---

## Error Handling

```swift
enum APIError: LocalizedError {
    case httpError(Int, Data)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .httpError(let code, let data):
            if let json = try? JSONDecoder().decode([String: String].self, from: data),
               let message = json["message"] { return message }
            return "Server error \(code)"
        case .decodingError(let e):
            return "Decode error: \(e)"
        }
    }
}
```

---

## Spatie QueryBuilder filters (Laravel)

So that iOS can pass `filter[user_id]=2`, on the backend:

```php
QueryBuilder::for(Listing::class)
    ->allowedFilters([
        AllowedFilter::exact('user_id'),
        AllowedFilter::exact('category_id'),
        AllowedFilter::callback('category_slug', fn($q, $v) =>
            $q->whereHas('category', fn($c) => $c->where('slug', $v))
        ),
        AllowedFilter::callback('min_price', fn($q, $v) => $q->where('price', '>=', $v)),
    ])
    ->allowedSorts(['newest', 'price_asc', 'price_desc', 'popular'])
```

> If a filter is not added to `allowedFilters` — it will return 400. Add all filters that iOS sends.
