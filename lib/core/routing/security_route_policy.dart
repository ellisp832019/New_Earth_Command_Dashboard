import '../../features/security/application/security_session_controller.dart';
import 'route_names.dart';

abstract final class SecurityRoutePolicy {
  static const Set<String> _publicWhileLockedPaths = {
    RouteNames.startup,
    RouteNames.securityLock,
  };

  static bool isPublicWhileLocked(Uri uri) {
    return _publicWhileLockedPaths.contains(uri.path);
  }

  static String? redirectForSession({
    required Uri requestedUri,
    required SecuritySessionState session,
  }) {
    if (session.isUnlocked && !session.isExpired) {
      return null;
    }

    if (isPublicWhileLocked(requestedUri)) {
      return null;
    }

    return RouteNames.securityLockWithResume(requestedUri.toString());
  }

  static String securityLockFrom(Uri currentUri) {
    return RouteNames.securityLockWithResume(currentUri.toString());
  }

  static String? resumeRouteFrom(Uri securityLockUri) {
    final resume = securityLockUri.queryParameters['resume'];
    if (resume == null || resume.isEmpty) {
      return null;
    }

    final parsedResume = Uri.tryParse(resume);
    if (parsedResume == null || parsedResume.path.isEmpty) {
      return null;
    }

    if (parsedResume.path == RouteNames.securityLock ||
        parsedResume.path == RouteNames.startup) {
      return null;
    }

    return resume;
  }
}
