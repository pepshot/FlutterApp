import 'backend_api.dart';
import 'booking_dto.dart';

abstract interface class BookingRepository {
  Future<BookingDto> getById(String id);
  Future<BookingDto> create(BookingDto value);
  Future<BookingDto> update(BookingDto value);
  Future<void> delete(String id);

  Future<List<BookingDto>> getAll();
}

class HttpBookingRepository implements BookingRepository {
  HttpBookingRepository({BackendApi? api}) : _api = api ?? BackendApi();

  final BackendApi _api;

  @override
  Future<List<BookingDto>> getAll() async =>
      (await _api.getList('/api/bookings'))
          .map((item) => BookingDto.fromJson(item as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> _body(BookingDto value) => value.toJson()
    ..remove('id')
    ..remove('status');

  @override
  Future<BookingDto> getById(String id) async => BookingDto.fromJson(
    await _api.get('/api/bookings/${Uri.encodeComponent(id)}'),
  );

  @override
  Future<BookingDto> create(BookingDto value) async =>
      BookingDto.fromJson(await _api.post('/api/bookings', _body(value)));

  @override
  Future<BookingDto> update(BookingDto value) async => BookingDto.fromJson(
    await _api.put(
      '/api/bookings/${Uri.encodeComponent(value.id)}',
      _body(value),
    ),
  );

  @override
  Future<void> delete(String id) =>
      _api.delete('/api/bookings/${Uri.encodeComponent(id)}');
}
