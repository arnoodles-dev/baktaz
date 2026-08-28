# Payment & Payout Plan — Chopper Client

**Goal:** Create HitPay Chopper client with request/response DTOs.

## Task 3: HitPay Chopper Client

**Files:**
- Create: `baktaz_server/lib/src/features/payment/data/service/hitpay_client.dart`
- Create: `baktaz_server/lib/src/features/payment/data/service/hitpay_requests.dart`
- Create: `baktaz_server/lib/src/features/payment/data/service/hitpay_responses.dart`

**Interfaces:**
- Consumes: `chopper` package
- Produces: `HitPayClient` Chopper service

- [ ] **Step 1: Create request DTOs**

```dart
// hitpay_requests.dart
final class CreateCheckoutRequest {
  final double amount;
  final String currency;
  final String referenceNumber;
  final String email;
  final String? name;
  final List<String> paymentMethods;
  final String? redirectUrl;
  final String? cancelUrl;

  CreateCheckoutRequest({
    required this.amount,
    required this.currency,
    required this.referenceNumber,
    required this.email,
    this.name,
    this.paymentMethods = const ['gcash', 'maya', 'credit_card', 'debit_card'],
    this.redirectUrl,
    this.cancelUrl,
  });
}

final class RefundRequest {
  final double amount;
  final String reason;

  RefundRequest({required this.amount, required this.reason});
}

final class CreatePayoutRequest {
  final double amount;
  final String currency;
  final String recipientId;
  final String referenceNumber;

  CreatePayoutRequest({
    required this.amount,
    required this.currency,
    required this.recipientId,
    required this.referenceNumber,
  });
}

final class CreateRecipientRequest {
  final String type;
  final String provider;
  final String phone;
  final String name;

  CreateRecipientRequest({
    required this.type,
    required this.provider,
    required this.phone,
    required this.name,
  });
}
```

- [ ] **Step 2: Create response DTOs**

```dart
// hitpay_responses.dart
final class HitPayCheckoutResponse {
  final String checkoutUrl;
  final String paymentId;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  HitPayCheckoutResponse({
    required this.checkoutUrl,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });
}

final class HitPayPaymentResponse {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String? providerFee;
  final String? settlementStatus;
  final String? paymentMethod;
  final Map<String, dynamic> metadata;

  HitPayPaymentResponse({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.providerFee,
    this.settlementStatus,
    this.paymentMethod,
    this.metadata = const {},
  });
}

final class HitPayPayoutResponse {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String? recipientId;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  HitPayPayoutResponse({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.recipientId,
    this.failureReason,
    this.metadata = const {},
  });
}

final class HitPayRecipientResponse {
  final String id;
  final String type;
  final String provider;
  final String phone;

  HitPayRecipientResponse({
    required this.id,
    required this.type,
    required this.provider,
    required this.phone,
  });
}
```

- [ ] **Step 3: Create Chopper client**

```dart
// hitpay_client.dart
import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';

part 'hitpay_client.chopper.dart';

@ChopperService()
abstract class HitPayClient extends ChopperService {
  static HitPayClient create([ChopperClient? client]) => _HitPayClientImpl(client);

  @POST('/v1/checkout')
  Future<Response<HitPayCheckoutResponse>> createCheckout(
    @Header('Authorization') String auth,
    @Body() CreateCheckoutRequest request,
  );

  @GET('/v1/payments/{id}')
  Future<Response<HitPayPaymentResponse>> getPayment(
    @Header('Authorization') String auth,
    @Path() String id,
  );

  @POST('/v1/payments/{id}/refund')
  Future<Response<HitPayRefundResponse>> refundPayment(
    @Header('Authorization') String auth,
    @Path() String id,
    @Body() RefundRequest request,
  );

  @POST('/v1/payouts')
  Future<Response<HitPayPayoutResponse>> createPayout(
    @Header('Authorization') String auth,
    @Body() CreatePayoutRequest request,
  );

  @GET('/v1/payouts/{id}')
  Future<Response<HitPayPayoutResponse>> getPayout(
    @Header('Authorization') String auth,
    @Path() String id,
  );

  @POST('/v1/recipients')
  Future<Response<HitPayRecipientResponse>> createRecipient(
    @Header('Authorization') String auth,
    @Body() CreateRecipientRequest request,
  );
}
```

- [ ] **Step 4: Run build_runner**

Run: `cd baktaz_server && fvm dart run build_runner build --delete-conflicting-outputs`
Expected: `hitpay_client.chopper.dart` generated

- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/payment/data/service/
git commit -m "feat(payment): add HitPay Chopper client"
```
