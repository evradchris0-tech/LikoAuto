/// Représente toutes les erreurs métier remontées de la couche data
/// vers la couche domain/presentation. Ne jamais propager d'Exception
/// brutes au-dessus du repository.
sealed class Failure {
  const Failure(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'Failure($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, super.cause});
  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expirée']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fields});
  final Map<String, String>? fields;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache local']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur est survenue'])
    : super(cause: null);
}
