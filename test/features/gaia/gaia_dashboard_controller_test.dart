import 'dart:convert';

import 'package:gaia_dashboard_module/gaia_dashboard_module.dart';
import 'package:gaia_integration_client/gaia_integration_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'refresh loads the merged programme summary and project officer states',
    () async {
      final controller = GaiaDashboardController(
        client: GaiaIntegrationClient(
          baseUri: Uri.parse('http://127.0.0.1:8765'),
          client: _dashboardClient(),
        ),
      );

      await controller.refresh();

      expect(
        controller.connectionState,
        GaiaDashboardConnectionState.connected,
      );
      expect(controller.programmeSummaryState, GaiaProgrammeSummaryState.ready);
      expect(controller.programmeSummaryStale, isFalse);
      expect(controller.programmeSummary?.summary.projectCount, 1);
      expect(
        controller.projectOfficerState,
        GaiaProjectOfficerSummaryState.ready,
      );
      expect(controller.projectOfficerSupported, isTrue);
      expect(controller.projectOfficerStale, isFalse);
      expect(controller.projectOfficerTopRecommendations, hasLength(1));
      expect(controller.projectOfficerPendingApprovalPackages, hasLength(1));
      expect(controller.projectOfficerRecentCompletedWork, hasLength(1));
      expect(controller.dataStale, isFalse);
      expect(controller.errorMessage, isNull);
    },
  );

  test(
    'refresh fails closed for incompatible and missing programme states',
    () async {
      final controller = GaiaDashboardController(
        client: GaiaIntegrationClient(
          baseUri: Uri.parse('http://127.0.0.1:8765'),
          client: _dashboardClient(
            incompatibleCompatibility: true,
            incompatibleProgrammeSummary: true,
            missingProjectOfficerCapabilities: true,
          ),
        ),
      );

      await controller.refresh();

      expect(
        controller.connectionState,
        GaiaDashboardConnectionState.incompatible,
      );
      expect(
        controller.programmeSummaryState,
        GaiaProgrammeSummaryState.incompatible,
      );
      expect(controller.programmeSummaryStale, isTrue);
      expect(controller.programmeSummaryError, isNotNull);
      expect(
        controller.projectOfficerState,
        GaiaProjectOfficerSummaryState.unavailable,
      );
      expect(controller.projectOfficerSupported, isFalse);
      expect(controller.projectOfficerStale, isTrue);
    },
  );
}

MockClient _dashboardClient({
  bool incompatibleCompatibility = false,
  bool incompatibleProgrammeSummary = false,
  bool missingProjectOfficerCapabilities = false,
}) {
  return MockClient((request) async {
    final path = request.url.path;
    switch (path) {
      case '/integration/v1/compatibility':
        return _json({
          'backend_product_version': '0.9.0',
          'minimum_supported_api_version': '0.9.0',
          'maximum_tested_api_version': '0.9.0',
          'integration_contract_version': 'gaia-v2',
          'client_package_version': '0.9.0',
          'backend_version': '0.9.0',
          'status': incompatibleCompatibility
              ? 'contract_mismatch'
              : 'compatible',
          'loopback_only': true,
          'capability_version': '0.9.0',
          'capabilities': ['embedded_operations_workspace', 'trust_alerts'],
          'capability_catalog': const [],
          'degraded_features': const [],
          'deprecation_warnings': const [],
        });
      case '/integration/v1/status':
        return _json({'backend': 'ok'});
      case '/integration/v1/projects':
        return _json(const []);
      case '/integration/v1/tasks/summary':
        return _json({
          'project_id': 'demo',
          'total': 2,
          'active': 1,
          'pending': 1,
          'completed': 0,
        });
      case '/integration/v1/approvals/summary':
        return _json({
          'project_id': 'demo',
          'total': 1,
          'active': 1,
          'pending': 1,
          'completed': 0,
        });
      case '/integration/v1/actions/summary':
        return _json({
          'project_id': 'demo',
          'total': 0,
          'proposed': 0,
          'awaiting_approval': 0,
          'approved': 0,
          'completed': 0,
          'failed': 0,
          'invalidated': 0,
          'rolled_back': 0,
        });
      case '/integration/v1/briefs/latest':
        return http.Response('null', 200);
      case '/integration/v1/receipts/latest':
        return http.Response('null', 200);
      case '/integration/v1/capabilities':
        return _json({
          'capability_version': '0.9.0',
          'capabilities': ['embedded_operations_workspace', 'trust_alerts'],
          'capability_catalog': const [],
          'degraded_features': const [],
          'signing_enabled': false,
          'signing_key_count': 0,
        });
      case '/signing/keys':
        return _json(const []);
      case '/provenance/manifests':
        return _json(const []);
      case '/trust/alerts':
        return _json([
          {
            'alert_id': 'alert-1',
            'alert_type': 'trust',
            'severity': 'warning',
            'status': 'open',
            'title': 'Trust alert',
            'message': 'Evidence needs review',
            'source_kind': 'project',
            'source_id': 'project-alpha',
            'created_at': '2026-08-06T08:00:00Z',
            'acknowledged_at': null,
            'metadata': const {},
          },
        ]);
      case '/retention/policies':
        return _json(const []);
      case '/retention/status':
        return _json({
          'policies': const [],
          'plans': const [],
          'receipts': const [],
        });
      case '/retention/report':
        return _json({
          'generated_at': '2026-08-06T00:00:00Z',
          'policy_count': 0,
          'plan_count': 0,
          'receipt_count': 0,
          'enabled_policy_count': 0,
          'issues': const [],
          'summary': const {},
        });
      case '/action-templates':
        return _json(const []);
      case '/integration/v1/programme/summary':
        if (incompatibleProgrammeSummary) {
          return http.Response(
            jsonEncode({'detail': 'programme summary incompatible'}),
            409,
          );
        }
        return _json({
          'generated_at': '2026-08-06T12:00:00Z',
          'selected_project_id': 'project-alpha',
          'selected_project': {
            'project_id': 'project-alpha',
            'project_name': 'Project Alpha',
          },
          'summary': {
            'project_count': 1,
            'health_status_counts': {'healthy': 1},
            'change_severity_counts': {'high': 1},
            'recommendation_state_counts': {'active': 1},
            'roadmap_state_counts': {'NOW': 1},
            'release_train_readiness_counts': {'READY': 1},
            'package_state_counts': {'approved': 1},
            'architecture_entity_count': 1,
            'architecture_relationship_count': 1,
            'cycle_count': 0,
            'unresolved_dependency_count': 0,
            'shared_dependency_count': 0,
            'orphan_count': 0,
            'trust_alert_count': 1,
            'provenance_manifest_count': 1,
            'stale_evidence_projects': const [],
          },
          'portfolio': {
            'health_portfolio': {
              'counts_by_status': {'healthy': 1},
            },
            'change_portfolio': {
              'counts_by_severity': {'high': 1},
            },
            'recommendation_portfolio': {
              'counts_by_state': {'active': 1},
            },
          },
          'architecture_registry': {
            'entities': const [
              {
                'entity_id': 'entity-1',
                'kind': 'package',
                'name': 'Shared Library',
              },
            ],
            'relationships': const [
              {
                'relationship_id': 'rel-1',
                'source_entity_id': 'entity-1',
                'target_entity_id': 'entity-2',
              },
            ],
          },
          'dependency_graph': {
            'snapshot': {'node_count': 1, 'edge_count': 1},
            'cycles': const [],
            'shared_dependencies': const [],
            'orphans': const [],
            'unresolved_findings': const [],
          },
          'impact_analysis': {
            'analyses': const [],
            'selected_analysis': null,
            'selected_change_findings': const [],
          },
          'change_proposals': {'recommendations': const []},
          'roadmap': {'roadmap_items': const []},
          'release_trains': {'release_trains': const []},
          'programme_packages': {'programme_packages': const []},
          'decisions': {
            'selected_work_packages': const [],
            'selected_contract': null,
          },
          'cross_project_evidence': {
            'provenance_manifests': const [],
            'selected_project_dependencies': const [],
            'selected_project_dependents': const [],
          },
        });
      case '/integration/v1/project-officer/capabilities':
        if (missingProjectOfficerCapabilities) {
          return http.Response(
            jsonEncode({'detail': 'project officer unavailable'}),
            404,
          );
        }
        return _json({
          'capability_version': '0.9.0',
          'capabilities': [
            'project_officer_portfolio',
            'project_officer_work_packages',
          ],
        });
      case '/integration/v1/project-officer/portfolio':
        return _json({
          'generated_at': '2026-08-06T00:00:00Z',
          'enabled_project_count': 1,
          'counts_by_status': {
            'healthy': 1,
            'attention': 0,
            'blocked': 0,
            'unknown': 0,
          },
          'projects': [
            {
              'project_id': 'project-alpha',
              'project_name': 'Project Alpha',
              'normalized_status': 'healthy',
              'evidence_freshness': 'fresh',
              'reason_codes': ['fresh_evidence'],
              'latest_snapshot': {
                'normalized_payload': {
                  'git_state': {
                    'branch': 'main',
                    'commit_sha': '0123456789abcdef',
                    'is_clean': true,
                  },
                  'configured_evidence': {
                    'evidence_freshness': {'state': 'fresh'},
                  },
                },
              },
            },
          ],
        });
      case '/integration/v1/project-officer/recommendations/portfolio':
        return _json({
          'recommendation_queue': [
            {
              'priority_tier': 'P1',
              'deterministic_score': '0.97',
              'project_id': 'project-alpha',
              'title': 'First recommendation',
              'concise_summary': 'Keep the latest evidence current.',
              'why_it_matters': 'Read-only command-centre summary.',
              'evidence_freshness': 'fresh',
              'lifecycle_state': 'active',
            },
          ],
          'projects': [
            {
              'project_id': 'project-alpha',
              'project_name': 'Project Alpha',
              'latest_lifecycle_state': 'blocked',
              'blocked_recommendation_count': 1,
              'latest_recommendations': [
                {
                  'blockers': [
                    {'blocker_description': 'Waiting on human review'},
                  ],
                },
              ],
            },
          ],
        });
      case '/integration/v1/project-officer/changes/portfolio':
        return _json({
          'projects': [
            {
              'project_id': 'project-alpha',
              'project_name': 'Project Alpha',
              'latest_health_status': 'attention',
              'latest_comparison_id': 'cmp-1',
              'latest_comparison_freshness': 'fresh',
              'stale_evidence': false,
            },
          ],
        });
      case '/integration/v1/project-officer/work-packages':
        if (request.url.query.contains('approval_state=under_review')) {
          return _json([
            {
              'project_id': 'project-alpha',
              'work_package_id': 'package-1',
              'title': 'Pending approval package',
              'current_revision_number': 3,
              'risk_classification': 'moderate',
              'approval_state': 'under_review',
              'staleness_state': 'fresh',
            },
          ]);
        }
        if (request.url.query.contains('approval_state=completed')) {
          return _json([
            {
              'project_id': 'project-alpha',
              'work_package_id': 'package-1',
              'title': 'Completed package',
              'current_revision_number': 3,
              'risk_classification': 'moderate',
              'approval_state': 'completed',
              'staleness_state': 'fresh',
            },
          ]);
        }
        return _json(const []);
      case '/integration/v1/project-officer/work-packages/package-1/outcomes':
        return _json([
          {
            'project_id': 'project-alpha',
            'work_package_id': 'package-1',
            'revision_number': 3,
            'outcome': 'completed',
            'recorded_at': '2026-08-06T12:10:00Z',
            'evidence_fingerprint': 'sha256:abcd',
          },
        ]);
      default:
        return http.Response('{}', 404);
    }
  });
}

http.Response _json(Object? body, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}
