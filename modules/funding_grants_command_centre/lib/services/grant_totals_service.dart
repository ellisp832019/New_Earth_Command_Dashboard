import '../models/grant_record.dart';
import '../models/grant_status.dart';

class GrantTotals {
  final double requested;
  final double approved;
  final double pending;
  final double rejected;
  final int totalApplications;

  const GrantTotals({
    required this.requested,
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.totalApplications,
  });
}

class GrantTotalsService {
  GrantTotals calculate(List<GrantRecord> grants) {
    double requested = 0;
    double approved = 0;
    double pending = 0;
    double rejected = 0;

    for (final grant in grants) {
      requested += grant.amountRequested;

      switch (grant.status.label) {
        case 'Approved':
        case 'Reporting Phase':
        case 'Closed':
          approved += grant.amountRequested;
          break;
        case 'Rejected':
          rejected += grant.amountRequested;
          break;
        case 'Submitted':
        case 'Under Review':
        case 'Ready to Submit':
          pending += grant.amountRequested;
          break;
      }
    }

    return GrantTotals(
      requested: requested,
      approved: approved,
      pending: pending,
      rejected: rejected,
      totalApplications: grants.length,
    );
  }
}
