import 'package:dio/dio.dart';

/// Erreur typée retournée par ApiClient.
/// Permet de distinguer les erreurs réseau des erreurs métier (4xx/5xx).
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

/// Erreur inattendue non couverte par les cas spécifiques.
final class UnexpectedApiException extends ApiException {
  const UnexpectedApiException(super.message);
}

/// Erreur réseau (pas de connexion, timeout, DNS).
final class NetworkException extends ApiException {
  const NetworkException([super.message = 'Vérifiez votre connexion internet.']);
}

/// Erreur 401 — token Firebase expiré ou invalide.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Session expirée. Reconnectez-vous.']);
}

/// Erreur 403 — permission insuffisante (PBAC).
final class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = "Vous n'avez pas la permission d'effectuer cette action."]);
}

/// Erreur 404 — ressource introuvable.
final class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Ressource introuvable.']);
}

/// Erreur 409 — conflit (ex : email déjà utilisé).
final class ConflictException extends ApiException {
  const ConflictException(super.message);
}

/// Erreur 422 — données invalides (validation NestJS).
final class ValidationException extends ApiException {
  const ValidationException(this.errors) : super('Données invalides.');
  final List<String> errors;
}

/// Erreur serveur 5xx.
final class ServerException extends ApiException {
  const ServerException([super.message = 'Erreur serveur. Réessayez plus tard.']);
}

/// Convertit une [DioException] en [ApiException] lisible.
ApiException apiExceptionFromDio(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const NetworkException();
  }

  final statusCode = e.response?.statusCode;
  final data = e.response?.data;

  switch (statusCode) {
    case 401:
      return const UnauthorizedException();
    case 403:
      return const ForbiddenException();
    case 404:
      return const NotFoundException();
    case 409:
      final msg = data is Map ? (data['message'] as String? ?? 'Conflit.') : 'Conflit.';
      return ConflictException(msg);
    case 422:
      final raw = data is Map ? data['message'] : null;
      final errors = raw is List ? raw.cast<String>() : <String>[];
      return ValidationException(errors);
    default:
      if (statusCode != null && statusCode >= 500) return const ServerException();
      return UnexpectedApiException('Erreur inattendue (${statusCode ?? 'inconnue'}).');
  }
}
