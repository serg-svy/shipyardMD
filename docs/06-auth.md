# 06 — Authentication

## Documentation
- [Sign in with Apple](https://developer.apple.com/documentation/sign_in_with_apple)
- [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)

---

## OTP (SMS) Auth

### iOS Flow

```swift
// 1. Request OTP
try await api.request(AuthEndpoint.sendOtp(phone: phone))

// 2. Verification
let response: AuthResponse = try await api.request(
    AuthEndpoint.verifyOtp(phone: phone, code: code)
)
KeychainService.shared.saveToken(response.token)   // Keychain ONLY, not UserDefaults — see 12-security.md
```

### Backend — OtpService

```php
public function send(string $phone): void
{
    // Invalidate old codes
    OtpCode::where('phone', $phone)
        ->whereNull('used_at')
        ->update(['used_at' => now()]);

    $code = (string) random_int(100000, 999999);
    OtpCode::create([
        'phone'      => $phone,
        'code'       => $code,
        'expires_at' => now()->addMinutes(10),
    ]);

    // Send via Twilio / another provider
}
```

### Twilio SMS

```php
Http::withBasicAuth($accountSid, $authToken)
    ->asForm()
    ->post("https://api.twilio.com/2010-04-01/Accounts/{$accountSid}/Messages.json", [
        'From' => $from,
        'To'   => $phone,
        'Body' => "Your code: {$code}. Valid 10 minutes.",
    ]);
```

`.env`:
```
TWILIO_ACCOUNT_SID=ACxxxxx
TWILIO_AUTH_TOKEN=xxxxx
TWILIO_FROM=+1234567890
```

---

## Apple Sign In

### Entitlement (required)
```xml
<key>com.apple.developer.applesignin</key>
<array><string>Default</string></array>
```

### iOS

```swift
import AuthenticationServices

struct AppleSignInButton: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                      let tokenData = credential.identityToken,
                      let token = String(data: tokenData, encoding: .utf8) else { return }

                Task {
                    let name = [credential.fullName?.givenName, credential.fullName?.familyName]
                        .compactMap { $0 }.joined(separator: " ")
                    try await authVM.loginWithApple(token: token, name: name, email: credential.email)
                }
            case .failure: break
            }
        }
        .frame(height: 50)
    }
}
```

### Backend

```php
// POST /v1/auth/apple
public function apple(Request $request): JsonResponse
{
    $appleId = $this->verifyAppleToken($request->identity_token);
    if (!$appleId) return response()->json(['message' => 'Invalid token'], 422);

    $user = User::firstOrCreate(
        ['apple_id' => $appleId],
        ['name' => $request->name ?? 'Apple User', 'email' => $request->email]
    );

    $token = $user->createToken('mobile', ['*'], now()->addDays(30))->plainTextToken;
    return response()->json(['user' => new UserResource($user), 'token' => $token]);
}

// Apple JWT verification (use firebase/php-jwt in production)
private function verifyAppleToken(string $token): ?string
{
    $parts = explode('.', $token);
    if (count($parts) !== 3) return null;
    $payload = json_decode(base64_decode(str_pad(
        strtr($parts[1], '-_', '+/'),
        strlen($parts[1]) % 4, '=', STR_PAD_RIGHT
    )), true);
    return $payload['sub'] ?? null;
}
```

> In production, verify the signature using Apple's public keys: `https://appleid.apple.com/auth/keys`  
> Package: `web-token/jwt-framework` or `firebase/php-jwt`

---

## Google Sign In

### iOS (via Google SDK)

```swift
import GoogleSignIn

GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
    guard let idToken = result?.user.idToken?.tokenString else { return }
    Task { try await authVM.loginWithGoogle(token: idToken) }
}
```

### Backend

```php
// Verification via Google tokeninfo endpoint
private function verifyGoogleToken(string $token): ?array
{
    $response = Http::get('https://oauth2.googleapis.com/tokeninfo', ['id_token' => $token]);
    if (!$response->ok()) return null;

    $payload = $response->json();
    // Verify the token belongs to our app
    if (($payload['aud'] ?? '') !== config('services.google.client_id')) return null;

    return $payload;
}
```

`.env`:
```
GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com
```

---

## Sanctum Token Management

```php
// config/sanctum.php
'expiration' => 60 * 24 * 30, // 30 days in minutes

// Create token
$token = $user->createToken('mobile', ['*'], now()->addDays(30))->plainTextToken;

// Logout (delete current token)
$request->user()->currentAccessToken()->delete();
```

### iOS — auto-login

```swift
var isLoggedIn: Bool {
    KeychainService.shared.getToken() != nil
}

// On app start
if isLoggedIn {
    try await refreshMe()   // GET /auth/me
}
```
