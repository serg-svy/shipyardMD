# 11 — Testing

## Documentation
- [XCTest](https://developer.apple.com/documentation/xctest)
- [Testing in Xcode](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
- [Laravel HTTP Tests](https://laravel.com/docs/testing)
- [PHPUnit](https://phpunit.de/documentation.html)

---

## Local Tests — Always Required

Run before every commit. No GitHub needed — just Xcode and the terminal.

---

## iOS — XCTest

### Structure

```
MyApp/
├── MyAppTests/                  # Unit tests
│   ├── ViewModels/
│   │   ├── AuthViewModelTests.swift
│   │   └── ListingsViewModelTests.swift
│   └── Network/
│       └── APIClientTests.swift
└── MyAppUITests/                # UI tests
    ├── AuthFlowTests.swift
    └── ListingFlowTests.swift
```

In `project.yml`:
```yaml
targets:
  MyAppTests:
    type: bundle.unit-test
    platform: iOS
    sources: [MyAppTests]
    dependencies:
      - target: MyApp

  MyAppUITests:
    type: bundle.ui-testing
    platform: iOS
    sources: [MyAppUITests]
    dependencies:
      - target: MyApp
```

### ViewModel Unit Test

```swift
import XCTest
@testable import MyApp

@MainActor
final class ListingsViewModelTests: XCTestCase {

    func test_load_setsListings() async throws {
        let vm = ListingsViewModel(api: MockAPIClient())
        await vm.load()
        XCTAssertFalse(vm.listings.isEmpty)
        XCTAssertFalse(vm.isLoading)
    }

    func test_load_setsErrorOnFailure() async throws {
        let vm = ListingsViewModel(api: FailingAPIClient())
        await vm.load()
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.listings.isEmpty)
    }
}
```

### Mock API Client

```swift
final class MockAPIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        // Return fake data from a JSON file
        let url = Bundle(for: type(of: self)).url(forResource: "mock_listings", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder.api.decode(T.self, from: data)
    }
}
```

Place `mock_listings.json` in the `MyAppTests/Fixtures/` folder.

### UI Test for a Critical Flow

```swift
final class AuthFlowTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]   // flag for mock data
        app.launch()
    }

    func test_login_withValidCode_opensHome() {
        // Enter phone number
        let phoneField = app.textFields["auth.phone_field"]
        phoneField.tap()
        phoneField.typeText("+1234567890")
        app.buttons["auth.send_code"].tap()

        // Enter OTP
        let codeField = app.textFields["auth.otp_field"]
        XCTAssertTrue(codeField.waitForExistence(timeout: 3))
        codeField.typeText("123456")
        app.buttons["auth.verify"].tap()

        // Verify that we landed on the home screen
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
}
```

Add `accessibilityIdentifier` to elements:
```swift
TextField("Phone", text: $phone)
    .accessibilityIdentifier("auth.phone_field")
```

### Running Tests Locally

```bash
# Unit tests
xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -testPlan MyApp \
  | xcpretty

# Or simply in Xcode: Cmd+U
```

---

## Backend — Laravel PHPUnit

### Structure

```
backend/tests/
├── Unit/
│   ├── Services/
│   │   └── OtpServiceTest.php
│   └── Models/
│       └── ListingTest.php
└── Feature/
    ├── Auth/
    │   └── OtpAuthTest.php
    └── Listings/
        ├── ListingIndexTest.php
        ├── ListingStoreTest.php
        └── ListingUpdateTest.php
```

### Feature Test for an API Endpoint

```php
// tests/Feature/Listings/ListingStoreTest.php

namespace Tests\Feature\Listings;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ListingStoreTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_create_listing(): void
    {
        Storage::fake('public');
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/v1/listings', [
            'title'       => 'iPhone 15 Pro',
            'description' => 'Great condition',
            'price'       => 999,
            'category_id' => 1,
            'condition'   => 'like_new',
            'city'        => 'Miami',
        ]);

        $response->assertStatus(201)
                 ->assertJsonPath('data.title', 'iPhone 15 Pro')
                 ->assertJsonPath('data.status', 'active');

        $this->assertDatabaseHas('listings', ['title' => 'iPhone 15 Pro']);
    }

    public function test_guest_cannot_create_listing(): void
    {
        $this->postJson('/api/v1/listings', [])->assertUnauthorized();
    }

    public function test_listing_requires_title(): void
    {
        $user = User::factory()->create();
        $this->actingAs($user)
             ->postJson('/api/v1/listings', ['price' => 100])
             ->assertUnprocessable()
             ->assertJsonValidationErrors(['title']);
    }
}
```

### Service Unit Test

```php
// tests/Unit/Services/OtpServiceTest.php

class OtpServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_send_creates_otp_code(): void
    {
        $service = new OtpService();
        $service->send('+1234567890');

        $this->assertDatabaseHas('otp_codes', [
            'phone'   => '+1234567890',
            'used_at' => null,
        ]);
    }

    public function test_send_invalidates_previous_codes(): void
    {
        $service = new OtpService();
        $service->send('+1234567890');
        $service->send('+1234567890'); // second call

        // Only one active code
        $this->assertDatabaseCount('otp_codes', 2);
        $this->assertEquals(1,
            OtpCode::where('phone', '+1234567890')->whereNull('used_at')->count()
        );
    }
}
```

### Running Tests Locally

```bash
# All tests
docker exec myapp_app php artisan test

# A specific file
docker exec myapp_app php artisan test tests/Feature/Listings/ListingStoreTest.php

# With coverage
docker exec myapp_app php artisan test --coverage
```

### .env.testing

```
APP_ENV=testing
DB_CONNECTION=pgsql
DB_DATABASE=myapp_testing    # separate database for tests!
MAIL_MAILER=array
QUEUE_CONNECTION=sync        # tests run synchronously
```

---

## CI/CD — Optional

If you use GitHub, add `.github/workflows/tests.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run iOS tests
        run: |
          xcodebuild test \
            -scheme MyApp \
            -destination 'platform=iOS Simulator,name=iPhone 16'

  backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgis/postgis:16-3.4
        env:
          POSTGRES_DB: myapp_testing
          POSTGRES_USER: myapp
          POSTGRES_PASSWORD: secret
    steps:
      - uses: actions/checkout@v4
      - name: Run Laravel tests
        run: |
          cd backend
          composer install
          cp .env.testing .env
          php artisan test
```

> This is optional — the minimum is running `php artisan test` locally and pressing `Cmd+U` in Xcode before every commit.
