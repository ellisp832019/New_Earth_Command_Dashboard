import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gaia_dashboard_module/gaia_dashboard_module.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/gaia/application/gaia_employee_providers.dart';
import 'package:new_earth_command_dashboard/features/gaia/presentation/gaia_employee_screen.dart';
import 'package:new_earth_command_dashboard/features/more/presentation/more_screen.dart';

void main() {
  testWidgets('disabled GAIA surface makes no backend request', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount += 1;
      return http.Response('{}', 200);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(false),
          gaiaEmployeeHttpClientProvider.overrideWithValue(client),
        ],
        child: const MaterialApp(home: GaiaEmployeeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GAIA read-only surface is disabled'), findsOneWidget);
    expect(requestCount, 0);
  });

  testWidgets('more route opens the GAIA employee surface when enabled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final client = _compatibleClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(true),
          gaiaEmployeeHttpClientProvider.overrideWithValue(client),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: RouteNames.more,
            routes: [
              GoRoute(
                path: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
              ),
              GoRoute(
                path: RouteNames.gaiaEmployee,
                builder: (context, state) => const GaiaEmployeeScreen(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GAIA AI Employee'), findsOneWidget);
    await tester.tap(find.text('GAIA AI Employee').first);
    await tester.pumpAndSettle();

    expect(find.text('GAIA integration surface'), findsOneWidget);
    expect(find.text('Project Officer'), findsWidgets);
    await tester.tap(find.text('Project Officer').first);
    await tester.pumpAndSettle();
    expect(find.text('Portfolio health'), findsOneWidget);
    expect(find.textContaining('review in GAIA Control Centre'), findsWidgets);
    expect(find.text('Read only'), findsWidgets);
    expect(find.textContaining('standalone GAIA Control Centre'), findsWidgets);
  });

  testWidgets('compatible backend renders the read-only workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(true),
          gaiaEmployeeHttpClientProvider.overrideWithValue(_compatibleClient()),
        ],
        child: const MaterialApp(home: GaiaEmployeeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GAIA integration surface'), findsOneWidget);
    expect(find.byType(GaiaDashboardView), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Capabilities'), findsWidgets);
    expect(find.text('Project Officer'), findsWidgets);
    expect(find.text('Trust'), findsWidgets);
    expect(find.text('Execution'), findsNothing);
    expect(find.text('Rollback'), findsNothing);
    expect(find.text('Retention apply'), findsNothing);
    await tester.tap(find.text('Project Officer').first);
    await tester.pumpAndSettle();
    expect(find.text('Portfolio health'), findsOneWidget);
    expect(find.text('Highest-priority recommendations'), findsOneWidget);
    expect(find.textContaining('review in GAIA Control Centre'), findsWidgets);
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
    expect(find.text('Handoff'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline backend fails closed and labels stale state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(true),
          gaiaEmployeeHttpClientProvider.overrideWithValue(_offlineClient()),
        ],
        child: const MaterialApp(home: GaiaEmployeeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GAIA integration surface'), findsOneWidget);
    expect(find.byType(GaiaDashboardView), findsOneWidget);
    expect(find.text('Connection issue'), findsOneWidget);
    expect(find.text('Stale cache'), findsOneWidget);
    expect(find.text('Open GAIA Control Centre'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incompatible backend renders safely', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gaiaEmployeeFeatureEnabledProvider.overrideWithValue(true),
          gaiaEmployeeHttpClientProvider.overrideWithValue(
            _incompatibleClient(),
          ),
        ],
        child: const MaterialApp(home: GaiaEmployeeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GAIA integration surface'), findsOneWidget);
    expect(find.byType(GaiaDashboardView), findsOneWidget);
    expect(find.text('Open GAIA Control Centre'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

MockClient _compatibleClient() {
  return MockClient((request) async {
    final path = request.url.path;
    switch (path) {
      case '/integration/v1/compatibility':
        return http.Response(
          jsonEncode({
            'backend_product_version': '0.7.0',
            'minimum_supported_api_version': '0.7.0',
            'maximum_tested_api_version': '0.7.0',
            'integration_contract_version': 'gaia-v2',
            'client_package_version': '0.7.0',
            'backend_version': '0.7.0',
            'status': 'compatible',
            'loopback_only': true,
            'capability_version': '0.7.0',
            'capabilities': ['embedded_operations_workspace', 'trust_alerts'],
            'capability_catalog': [
              {
                'capability_id': 'embedded_operations_workspace',
                'version': '0.7.0',
                'state': 'enabled',
                'summary': 'Embedded operations workspace',
                'gated_by': const [],
                'requires_signing': false,
                'enabled': true,
              },
              {
                'capability_id': 'trust_alerts',
                'version': '0.7.0',
                'state': 'enabled',
                'summary': 'Trust alerts',
                'gated_by': const [],
                'requires_signing': false,
                'enabled': true,
              },
            ],
            'degraded_features': const [],
            'deprecation_warnings': const [],
          }),
          200,
        );
      case '/integration/v1/status':
        return http.Response(jsonEncode({'backend': 'ok'}), 200);
      case '/integration/v1/projects':
        return http.Response(jsonEncode([]), 200);
      case '/integration/v1/tasks/summary':
        return http.Response(
          jsonEncode({
            'project_id': 'demo',
            'total': 2,
            'active': 1,
            'pending': 1,
            'completed': 0,
          }),
          200,
        );
      case '/integration/v1/approvals/summary':
        return http.Response(
          jsonEncode({
            'project_id': 'demo',
            'total': 1,
            'active': 1,
            'pending': 1,
            'completed': 0,
          }),
          200,
        );
      case '/integration/v1/actions/summary':
        return http.Response(
          jsonEncode({
            'project_id': 'demo',
            'total': 0,
            'proposed': 0,
            'awaiting_approval': 0,
            'approved': 0,
            'completed': 0,
            'failed': 0,
            'invalidated': 0,
            'rolled_back': 0,
          }),
          200,
        );
      case '/integration/v1/briefs/latest':
        return http.Response('null', 200);
      case '/integration/v1/receipts/latest':
        return http.Response(
          jsonEncode({
            'receipt_id': 'receipt-1',
            'action_id': 'action-1',
            'manifest_id': 'manifest-1',
            'manifest_version': 1,
            'target_path': 'workspace/summary.md',
            'resulting_hash': 'abc123',
            'timestamp': '2026-08-06T00:00:00Z',
            'chain_id': 'chain-1',
            'chain_sequence': 1,
            'previous_receipt_hash': null,
            'receipt_content_hash': 'content-1',
            'verification_status': 'valid',
          }),
          200,
        );
      case '/integration/v1/project-officer/capabilities':
        return http.Response(
          jsonEncode({
            'capability_version': '0.9.0',
            'capabilities': [
              'project_officer_portfolio',
              'project_officer_work_packages',
            ],
          }),
          200,
        );
      case '/integration/v1/project-officer/portfolio':
        return http.Response(
          jsonEncode({
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
          }),
          200,
        );
      case '/integration/v1/project-officer/recommendations/portfolio':
        return http.Response(
          jsonEncode({
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
          }),
          200,
        );
      case '/integration/v1/project-officer/changes/portfolio':
        return http.Response(
          jsonEncode({
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
          }),
          200,
        );
      case '/integration/v1/project-officer/work-packages':
        if (request.url.query.contains('approval_state=under_review')) {
          return http.Response(
            jsonEncode([
              {
                'project_id': 'project-alpha',
                'work_package_id': 'package-1',
                'title': 'Pending approval package',
                'current_revision_number': 3,
                'risk_classification': 'moderate',
                'approval_state': 'under_review',
                'staleness_state': 'fresh',
              },
            ]),
            200,
          );
        }
        if (request.url.query.contains('approval_state=completed')) {
          return http.Response(
            jsonEncode([
              {
                'project_id': 'project-alpha',
                'work_package_id': 'package-1',
                'title': 'Completed package',
                'current_revision_number': 3,
                'risk_classification': 'moderate',
                'approval_state': 'completed',
                'staleness_state': 'fresh',
              },
            ]),
            200,
          );
        }
        return http.Response(jsonEncode([]), 200);
      case '/integration/v1/project-officer/work-packages/package-1/outcomes':
        return http.Response(
          jsonEncode([
            {
              'project_id': 'project-alpha',
              'work_package_id': 'package-1',
              'revision_number': 3,
              'outcome': 'completed',
              'recorded_at': '2026-08-06T12:10:00Z',
              'evidence_fingerprint': 'sha256:abcd',
            },
          ]),
          200,
        );
      case '/action-templates':
        return http.Response(jsonEncode([]), 200);
      case '/retention/policies':
        return http.Response(jsonEncode([]), 200);
      case '/retention/status':
        return http.Response(
          jsonEncode({'policies': [], 'plans': [], 'receipts': []}),
          200,
        );
      case '/integration/v1/capabilities':
        return http.Response(
          jsonEncode({
            'capability_version': '0.7.0',
            'capabilities': ['embedded_operations_workspace', 'trust_alerts'],
            'capability_catalog': const [],
            'degraded_features': const [],
            'signing_enabled': false,
            'signing_key_count': 0,
          }),
          200,
        );
      case '/signing/keys':
        return http.Response(jsonEncode([]), 200);
      case '/provenance/manifests':
        return http.Response(jsonEncode([]), 200);
      case '/trust/alerts':
        return http.Response(
          jsonEncode([
            {
              'alert_id': 'alert-1',
              'alert_type': 'provenance',
              'severity': 'warning',
              'status': 'open',
              'title': 'Receipt chain has a gap',
              'message': 'A stale receipt needs review.',
              'source_kind': 'receipt_chain',
              'source_id': 'chain-1',
              'created_at': '2026-08-06T00:00:00Z',
              'acknowledged_at': null,
              'metadata': const {},
            },
          ]),
          200,
        );
      case '/retention/report':
        return http.Response(
          jsonEncode({
            'generated_at': '2026-08-06T00:00:00Z',
            'policy_count': 0,
            'plan_count': 0,
            'receipt_count': 1,
            'enabled_policy_count': 0,
            'issues': const [],
            'summary': const {},
          }),
          200,
        );
      default:
        return http.Response('{}', 404);
    }
  });
}

MockClient _offlineClient() {
  return MockClient((request) async {
    return http.Response(
      jsonEncode({'detail': 'offline'}),
      503,
      headers: const {'content-type': 'application/json'},
    );
  });
}

MockClient _incompatibleClient() {
  return MockClient((request) async {
    final path = request.url.path;
    if (path == '/integration/v1/compatibility') {
      return http.Response(
        jsonEncode({
          'backend_product_version': '0.6.0',
          'minimum_supported_api_version': '0.8.0',
          'maximum_tested_api_version': '0.8.0',
          'integration_contract_version': 'gaia-v1',
          'client_package_version': '0.7.0',
          'backend_version': '0.6.0',
          'status': 'contract_mismatch',
          'loopback_only': true,
          'capability_version': '0.6.0',
          'capabilities': const [],
          'capability_catalog': const [],
          'degraded_features': const ['embedded_operations_workspace'],
          'deprecation_warnings': const ['unsupported contract version'],
        }),
        200,
      );
    }
    return http.Response('{}', 200);
  });
}
