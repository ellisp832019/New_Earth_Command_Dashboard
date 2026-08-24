import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/governed_status/domain/governed_status.dart';

void main() {
  final scope = GovernedStatusScope(
    canonicalId: 'new-earth-command-dashboard',
    displayName: 'New Earth Command Dashboard',
    projectId: 'dashboard-local-id',
  );

  test('preserves canonical scope separately from display name', () {
    expect(scope.canonicalId, isNot(scope.displayName));
    expect(scope.canonicalProjectId, scope.canonicalId);
    expect(GovernedStatusEnvelope(requestedScope: scope).requestedScope, scope);
    expect(GovernedStatusContract.version, '1.0');
    expect(
      GovernedStatusEnvelope(requestedScope: scope).contractVersion,
      GovernedStatusContract.version,
    );
  });

  test('keeps each authority layer separate and local values labelled', () {
    final record = GovernedStatusRecord(
      scope: scope,
      declared: DeclaredStatusLayer(owner: 'Company', contractVersion: '1.0'),
      observed: ObservedStatusLayer(engineeringHealth: 'warning'),
      interpreted: InterpretedStatusLayer(
        operationalPriority: GaiaOperationalPriority.high,
        recommendation: 'Review evidence',
      ),
      local: LocalOperationalStatusLayer(
        localPriority: 'local-high',
        localProgress: 0.4,
        localNextAction: 'Confirm scope',
      ),
      approval: HumanApprovalState.pending,
    );

    expect(record.declared!.owner, 'Company');
    expect(record.observed!.engineeringHealth, 'warning');
    expect(
      record.interpreted!.operationalPriority,
      GaiaOperationalPriority.high,
    );
    expect(record.local!.localPriority, 'local-high');
    expect(record.approval, HumanApprovalState.pending);
  });

  test('keeps NEOS severity distinct from GAIA priority', () {
    expect(NeosFindingSeverity.blocker, isNot(GaiaOperationalPriority.urgent));
    final finding = const GovernedStatusFinding(
      id: 'finding-1',
      severity: NeosFindingSeverity.blocker,
      description: 'Observed issue',
    );
    final interpretation = InterpretedStatusLayer(
      operationalPriority: GaiaOperationalPriority.normal,
      recommendation: 'Prepare review',
    );
    expect(finding.severity, NeosFindingSeverity.blocker);
    expect(interpretation.operationalPriority, GaiaOperationalPriority.normal);
  });

  test('recommendations do not change independent approval', () {
    final record = GovernedStatusRecord(
      scope: scope,
      interpreted: InterpretedStatusLayer(
        operationalPriority: GaiaOperationalPriority.urgent,
        recommendation: 'Approve work package',
      ),
    );
    expect(record.interpreted!.recommendation, isNotNull);
    expect(record.approval, HumanApprovalState.unknown);
  });

  test('represents source metadata freshness, provenance, and version', () {
    final observedAt = DateTime.utc(2026, 8, 1);
    final retrievedAt = DateTime.utc(2026, 8, 2);
    final metadata = GovernedStatusSourceMetadata(
      source: GovernedStatusSource.neos,
      authority: GovernedStatusAuthority.neos,
      availability: GovernedStatusAvailability.stale,
      scope: scope,
      schemaVersion: '1.3.0',
      observedAt: observedAt,
      retrievedAt: retrievedAt,
      stale: true,
      provenanceReferences: ['report:123'],
    );
    expect(metadata.observedAt, observedAt);
    expect(metadata.retrievedAt, retrievedAt);
    expect(metadata.provenanceReferences, ['report:123']);
  });

  test('represents partial, unavailable, invalid, and unsupported sources', () {
    for (final availability in [
      GovernedStatusAvailability.partial,
      GovernedStatusAvailability.unavailable,
      GovernedStatusAvailability.invalid,
      GovernedStatusAvailability.unsupported,
    ]) {
      final metadata = GovernedStatusSourceMetadata(
        source: GovernedStatusSource.platformCore,
        authority: GovernedStatusAuthority.platformCore,
        availability: availability,
        scope: scope,
        partial: availability == GovernedStatusAvailability.partial,
        failureCategory: availability == GovernedStatusAvailability.unsupported
            ? GovernedStatusFailureCategory.unsupportedScope
            : null,
      );
      expect(metadata.availability, availability);
    }
  });

  test('rejects empty identity and mismatched source authority', () {
    expect(
      () => GovernedStatusScope(canonicalId: '', displayName: 'Unnamed'),
      throwsArgumentError,
    );
    expect(
      () => GovernedStatusSourceMetadata(
        source: GovernedStatusSource.neos,
        authority: GovernedStatusAuthority.platformCore,
        availability: GovernedStatusAvailability.available,
        scope: scope,
      ),
      throwsArgumentError,
    );
  });

  test('rejects records and metadata outside the requested scope', () {
    final otherScope = GovernedStatusScope(
      canonicalId: 'other-project',
      displayName: 'Other Project',
    );
    expect(
      () => GovernedStatusEnvelope(
        requestedScope: scope,
        records: [GovernedStatusRecord(scope: otherScope)],
      ),
      throwsArgumentError,
    );
    expect(
      () => GovernedStatusEnvelope(
        requestedScope: scope,
        sourceMetadata: [
          GovernedStatusSourceMetadata(
            source: GovernedStatusSource.neos,
            authority: GovernedStatusAuthority.neos,
            availability: GovernedStatusAvailability.unsupported,
            scope: otherScope,
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('one source failure preserves other layers', () {
    final envelope = GovernedStatusEnvelope(
      requestedScope: scope,
      records: [
        GovernedStatusRecord(
          scope: scope,
          declared: DeclaredStatusLayer(canonicalId: scope.canonicalId),
        ),
      ],
      sourceFailures: [
        GovernedStatusSourceFailure(
          source: GovernedStatusSource.neos,
          category: GovernedStatusFailureCategory.unavailable,
          scope: scope,
        ),
      ],
      partial: true,
    );
    expect(envelope.records.single.declared, isNotNull);
    expect(envelope.sourceFailures.single.source, GovernedStatusSource.neos);
  });

  test('all-source failure and empty results do not fabricate records', () {
    final envelope = GovernedStatusEnvelope(
      requestedScope: scope,
      sourceFailures: [
        GovernedStatusSourceFailure(
          source: GovernedStatusSource.platformCore,
          category: GovernedStatusFailureCategory.unavailable,
          scope: scope,
        ),
        GovernedStatusSourceFailure(
          source: GovernedStatusSource.neos,
          category: GovernedStatusFailureCategory.unavailable,
          scope: scope,
        ),
      ],
      partial: true,
    );
    expect(envelope.records, isEmpty);
  });

  test('conflicts retain categories, sources, and no automatic winner', () {
    final conflict = GovernedStatusConflict(
      category: GovernedStatusConflictCategory.ownerMismatch,
      affectedFieldOrScope: 'owner',
      participatingSources: [
        GovernedStatusSource.platformCore,
        GovernedStatusSource.neos,
      ],
      description: 'Declared and observed owners differ',
    );
    final envelope = GovernedStatusEnvelope(
      requestedScope: scope,
      conflicts: [conflict],
    );
    expect(envelope.conflicts.single.participatingSources, hasLength(2));
    expect(envelope.conflicts.single.blocking, isNull);
  });

  test('aggregate counts do not create finding records', () {
    final observed = ObservedStatusLayer(aggregateFindingCount: 3);
    expect(observed.aggregateFindingCount, 3);
    expect(observed.findings, isEmpty);
  });

  test('collections are defensively copied and unmodifiable', () {
    final refs = <String>['evidence:1'];
    final metadata = GovernedStatusSourceMetadata(
      source: GovernedStatusSource.gaia,
      authority: GovernedStatusAuthority.gaia,
      availability: GovernedStatusAvailability.available,
      scope: scope,
      provenanceReferences: refs,
    );
    refs.add('evidence:2');
    expect(metadata.provenanceReferences, ['evidence:1']);
    expect(
      () => metadata.provenanceReferences.add('evidence:3'),
      throwsUnsupportedError,
    );
  });

  test('defensively copies all nested collection values', () {
    final interfaces = <String>['interface-1'];
    final dependencies = <String>['dependency-1'];
    final findings = <GovernedStatusFinding>[
      const GovernedStatusFinding(
        id: 'finding-1',
        severity: NeosFindingSeverity.info,
        description: 'Informational',
      ),
    ];
    final questions = <String>['What needs review?'];
    final flags = <String>['local-only'];
    final declared = DeclaredStatusLayer(
      interfaces: interfaces,
      dependencies: dependencies,
    );
    final observed = ObservedStatusLayer(findings: findings);
    final interpreted = InterpretedStatusLayer(
      operationalPriority: GaiaOperationalPriority.low,
      reviewQuestions: questions,
    );
    final local = LocalOperationalStatusLayer(localOperationalFlags: flags);

    interfaces.add('interface-2');
    dependencies.add('dependency-2');
    findings.clear();
    questions.add('Another question');
    flags.add('changed');

    expect(declared.interfaces, ['interface-1']);
    expect(declared.dependencies, ['dependency-1']);
    expect(observed.findings, hasLength(1));
    expect(interpreted.reviewQuestions, ['What needs review?']);
    expect(local.localOperationalFlags, ['local-only']);
  });

  test('reader contract is implemented by a read-only fake', () async {
    final reader = _FakeGovernedStatusReader(
      GovernedStatusEnvelope(requestedScope: scope),
    );
    final result = await reader.load(scope: scope);
    expect(result.requestedScope, scope);
  });
}

class _FakeGovernedStatusReader implements GovernedStatusReader {
  _FakeGovernedStatusReader(this.envelope);

  final GovernedStatusEnvelope envelope;

  @override
  Future<GovernedStatusEnvelope> load({
    required GovernedStatusScope scope,
  }) async {
    return envelope;
  }
}
