import 'package:flame/components.dart';

/// Object pool for reusing game components to reduce memory allocations
class ObjectPool<T extends Component> {
  final List<T> _available = [];
  final List<T> _inUse = [];
  final T Function() _factory;
  final int _initialSize;
  final int _maxSize;

  ObjectPool({
    required T Function() factory,
    int initialSize = 20,
    int maxSize = 100,
  })  : _factory = factory,
        _initialSize = initialSize,
        _maxSize = maxSize;

  /// Initialize pool with initial objects
  void initialize() {
    for (int i = 0; i < _initialSize; i++) {
      _available.add(_factory());
    }
  }

  /// Get an object from the pool
  T obtain() {
    T object;
    
    if (_available.isNotEmpty) {
      object = _available.removeLast();
    } else {
      // Create new object if pool is empty and under max size
      if (_inUse.length < _maxSize) {
        object = _factory();
      } else {
        // Reuse oldest object if at max capacity
        object = _inUse.removeAt(0);
      }
    }
    
    _inUse.add(object);
    return object;
  }

  /// Return an object to the pool
  void release(T object) {
    if (_inUse.remove(object)) {
      // Reset object state if needed (implement PoolableComponent interface)
      _available.add(object);
    }
  }

  /// Release all in-use objects
  void releaseAll() {
    _available.addAll(_inUse);
    _inUse.clear();
  }

  /// Clear the pool
  void clear() {
    _available.clear();
    _inUse.clear();
  }

  /// Pool statistics
  int get availableCount => _available.length;
  int get inUseCount => _inUse.length;
  int get totalCount => _available.length + _inUse.length;
}

/// Interface for components that can be pooled
abstract class PoolableComponent {
  void reset();
}
