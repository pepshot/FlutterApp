import 'dart:async';

typedef ListState<T> = ({List<T>? items, bool failed});

class ListBloc<T> {
  ListBloc(Future<List<T>> Function() load) : this.searchable((_) => load());

  ListBloc.searchable(this._load);

  final Future<List<T>> Function(String) _load;
  final _states = StreamController<ListState<T>>();
  Timer? _debounce;
  String _query = '';
  int _requestId = 0;

  Stream<ListState<T>> get states => _states.stream;

  void searchChanged(String query) {
    _query = query;
    // Ignore results for the previous query during the debounce interval.
    ++_requestId;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), refresh);
  }

  Future<void> refresh() async {
    if (_states.isClosed) return;
    _debounce?.cancel();
    final requestId = ++_requestId;
    _states.add((items: null, failed: false));
    try {
      final items = await _load(_query);
      if (requestId == _requestId) {
        _states.add((items: items, failed: false));
      }
    } catch (_) {
      if (requestId == _requestId) {
        _states.add((items: null, failed: true));
      }
    }
  }

  void dispose() {
    _debounce?.cancel();
    ++_requestId;
    unawaited(_states.close());
  }
}
