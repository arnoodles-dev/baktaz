# Payment & Payout Architecture Spec — Server Architecture

**Date:** 2026-08-28
**Parent Spec:** `docs/superpowers/specs/payment/00-overview.md`

## 4. Server Architecture

### 4.1 Feature Structure

```
baktaz_server/lib/src/features/payment/
├── endpoint/
│   ├── payment_endpoint.dart       # User payment actions
│   ├── payout_endpoint.dart        # User payout actions
│   └── webhook_endpoint.dart       # HitPay callbacks (internal)
├── domain/
│   └── interface/
│       ├── i_payment_repository.dart   # Merged payment + payout repo
│       └── i_payment_provider.dart     # Merged provider interface
└── data/
    ├── repository/
    │   └── payment_repository.dart     # Implements IPaymentRepository
    └── service/
        ├── hitpay_service.dart          # HitPayService - implements IPaymentProvider
        ├── hitpay_client.dart           # Chopper @ChopperService
        └── hitpay_dtos.dart            # Request/response DTOs
```

### 4.2 Provider Interface (Merged)

```dart
// domain/interface/i_payment_provider.dart
abstract interface class IPaymentProvider {
  // Payments
  Future<Payment> createPayment(Session session, Payment payment);
  Future<PaymentStatus> getPaymentStatus(Session session, UuidValue paymentId);
  Future<Payment> refundPayment(Session session, UuidValue paymentId, {double? amount});

  // Payouts
  Future<Payout> createPayout(Session session, Payout payout);
  Future<PayoutStatus> getPayoutStatus(Session session, UuidValue payoutId);
  Future<PayoutAccount> createRecipient(Session session, PayoutAccount account);

  // Webhooks
  Future<void> handlePaymentWebhook(Session session, String payload, Map<String, String> headers);
  Future<void> handlePayoutWebhook(Session session, String payload, Map<String, String> headers);
}
```

### 4.3 Repository Interface (Merged)

```dart
// domain/interface/i_payment_repository.dart
abstract interface class IPaymentRepository {
  // Payments
  Future<Payment> createPaymentIntent(Session session, Payment payment);
  Future<Payment> getPayment(Session session, UuidValue id);
  Future<void> confirmPayment(Session session, UuidValue id);
  Future<Payment> refundPayment(Session session, UuidValue id, {double? amount});

  // Payment methods
  Future<PaymentAccount> createPaymentAccount(Session session, PaymentAccount account);
  Future<List<PaymentAccount>> listPaymentAccounts(Session session);
  Future<void> deletePaymentAccount(Session session, UuidValue id);

  // Payouts
  Future<Payout> createPayout(Session session, Payout payout);
  Future<Payout> getPayout(Session session, UuidValue id);
  Future<List<Payout>> listWinnerPayouts(Session session, UuidValue challengeId);
  Future<PayoutAccount> createPayoutAccount(Session session, PayoutAccount account);
  Future<List<PayoutAccount>> listPayoutAccounts(Session session);
  Future<void> deletePayoutAccount(Session session, UuidValue id);

  // Challenge entries
  Future<ChallengeEntry> getOrCreateEntry(Session session, UuidValue challengeId, UuidValue userId);
  Future<List<ChallengeEntry>> listChallengeEntries(Session session, UuidValue challengeId);
}
```

### 4.4 Service Implementation

```dart
// data/service/hitpay_service.dart
@LazySingleton(as: IPaymentProvider)
final class HitPayService implements IPaymentProvider {
  HitPayService(this._hitPayClient);
  final HitPayClient _hitPayClient;

  // Uses Chopper client to call HitPay API
  // No business logic, no DB access
}
```

### 4.5 Chopper Client

```dart
// data/service/hitpay_client.dart
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

### 4.6 DI Registration

```dart
// service_locator.config.dart (generated)
gh.lazySingleton<HitPayClient>(() => HitPayClient.create(chopperClient));
gh.lazySingleton<IPaymentProvider>(() => HitPayService(hitPayClient: gh<HitPayClient>()));
gh.lazySingleton<IPaymentRepository>(() => PaymentRepository(provider: gh<IPaymentProvider>()));
```
