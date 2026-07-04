import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';

enum EngineeringAccessRole { engineer, lead, admin }

class EngineeringAccessPolicy {
  const EngineeringAccessPolicy({
    required this.role,
    required this.canEdit,
    required this.canExport,
    required this.canImport,
  });

  const EngineeringAccessPolicy.localOnly()
    : role = EngineeringAccessRole.engineer,
      canEdit = true,
      canExport = true,
      canImport = true;

  final EngineeringAccessRole role;
  final bool canEdit;
  final bool canExport;
  final bool canImport;

  String get label {
    return switch (role) {
      EngineeringAccessRole.engineer => 'Engineer',
      EngineeringAccessRole.lead => 'Lead Engineer',
      EngineeringAccessRole.admin => 'Admin',
    };
  }
}

abstract class EngineeringKnowledgeEngineAdapter {
  const EngineeringKnowledgeEngineAdapter();

  Future<void> open(BuildContext context);
}

class LocalEngineeringKnowledgeEngineAdapter
    extends EngineeringKnowledgeEngineAdapter {
  const LocalEngineeringKnowledgeEngineAdapter();

  @override
  Future<void> open(BuildContext context) async {
    context.push(RouteNames.modulePackage('26_OMEGA_KNOWLEDGE_ENGINE'));
  }
}

abstract class EngineeringGaiaAssistantAdapter {
  const EngineeringGaiaAssistantAdapter();

  Future<void> open(BuildContext context);
}

class LocalEngineeringGaiaAssistantAdapter
    extends EngineeringGaiaAssistantAdapter {
  const LocalEngineeringGaiaAssistantAdapter();

  @override
  Future<void> open(BuildContext context) async {
    context.push(RouteNames.voiceAssistant);
  }
}
