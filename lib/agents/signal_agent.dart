// CIRO — Signal Agent
// Responsibility: Collects raw signals from all configured sources and
// normalizes them to the standard Signal schema (lib/models/signal.dart).
// MVP: Returns mock data. Swap data source here for real API integration.
//
// Input:  Optional list of SignalSource filters
// Output: List<Signal> sorted by timestamp (newest first)

import '../models/signal.dart';
import '../data/mock_signals.dart';

class SignalAgent {
  /// Collects and normalizes signals from all active sources.
  List<Signal> collectSignals({List<SignalSource>? sources}) {
    final all = mockSignals;
    if (sources == null || sources.isEmpty) return all;
    return all.where((s) => sources.contains(s.source)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
