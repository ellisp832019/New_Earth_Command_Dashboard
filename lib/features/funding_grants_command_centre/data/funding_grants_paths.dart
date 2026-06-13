import 'dart:io';

import 'package:path/path.dart' as path;

class FundingGrantsPaths {
  static const String omegaRoot =
      r'D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY\09_GRANTS_DONATIONS_AND_FUNDING';
  static const String oldOmegaRoot =
      r'D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY\INNOVATION_GRANTS';

  static final String trackerMasterFolder = path.join(
    omegaRoot,
    '00_GRANT_TRACKER_MASTER',
  );
  static final String trackerJsonPath = path.join(
    trackerMasterFolder,
    'grant_tracker.json',
  );
  static final String trackerCsvPath = path.join(
    trackerMasterFolder,
    'grant_tracker.csv',
  );
  static final String dashboardConfigPath = path.join(
    trackerMasterFolder,
    'dashboard_config.json',
  );

  static final String activeApplicationsPath = path.join(
    omegaRoot,
    '01_ACTIVE_APPLICATIONS',
  );
  static final String submittedApplicationsPath = path.join(
    omegaRoot,
    '02_SUBMITTED_APPLICATIONS',
  );
  static final String approvedGrantsPath = path.join(
    omegaRoot,
    '03_APPROVED_GRANTS',
  );
  static final String rejectedOrPausedPath = path.join(
    omegaRoot,
    '04_REJECTED_OR_PAUSED',
  );
  static final String partnerLettersPath = path.join(
    omegaRoot,
    '05_PARTNERS_AND_SUPPORT_LETTERS',
  );
  static final String evidenceLibraryPath = path.join(
    omegaRoot,
    '06_EVIDENCE_LIBRARY',
  );
  static final String budgetTemplatesPath = path.join(
    omegaRoot,
    '07_BUDGET_TEMPLATES',
  );
  static final String reportingAndClaimsPath = path.join(
    omegaRoot,
    '08_REPORTING_AND_CLAIMS',
  );
  static final String lessonsAndFeedbackPath = path.join(
    omegaRoot,
    '09_LESSONS_AND_FEEDBACK',
  );
  static final String opportunityResearchPath = path.join(
    omegaRoot,
    '10_OPPORTUNITY_RESEARCH',
  );
  static final String complianceAndRiskPath = path.join(
    omegaRoot,
    '11_COMPLIANCE_AND_RISK',
  );
  static final String meetingsAndCallsPath = path.join(
    omegaRoot,
    '12_MEETINGS_AND_CALLS',
  );
  static final String submissionArchivePath = path.join(
    omegaRoot,
    '13_SUBMISSION_ARCHIVE',
  );

  static final String moduleTemplatesPath = path.join(
    Directory.current.path,
    'modules',
    'funding_grants_command_centre',
    'templates',
  );

  static String normalizeOmegaPath(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value.replaceFirst(oldOmegaRoot, omegaRoot);
  }
}
