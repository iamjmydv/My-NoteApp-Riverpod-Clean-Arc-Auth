
abstract class UseCaseWithParams<T,P> {
  Future<T> call(P params);
}

abstract class UseCase<T> {
  Future<T> call();
}

class NoParams {
  const NoParams();
}