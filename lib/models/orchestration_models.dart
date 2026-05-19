// CIRO - Structured orchestration outputs for resource decisions,
// stakeholder messaging, multi-crisis coordination, and Antigravity traces.

import 'crisis.dart';
import 'signal.dart';

class SignalAssessment {
  final SignalSource source;
  final String sourceLabel;
  final double credibility;
  final double geolocationConfidence;
  final double urgencyScore;
  final double contradictionLevel;
  final String finding;

  const SignalAssessment({
    required this.source,
    required this.sourceLabel,
    required this.credibility,
    required this.geolocationConfidence,
    required this.urgencyScore,
    required this.contradictionLevel,
    required this.finding,
  });

  Map<String, dynamic> toJson() => {
        'source': source.name,
        'label': sourceLabel,
        'credibility': credibility,
        'geolocationConfidence': geolocationConfidence,
        'urgencyScore': urgencyScore,
        'contradictionLevel': contradictionLevel,
        'finding': finding,
      };
}

class CrisisEvolution {
  final String affectedRadius;
  final int affectedPopulation;
  final String expectedDuration;
  final String peakImpactTime;
  final String spreadRisk;
  final String uncertaintyRange;

  const CrisisEvolution({
    required this.affectedRadius,
    required this.affectedPopulation,
    required this.expectedDuration,
    required this.peakImpactTime,
    required this.spreadRisk,
    required this.uncertaintyRange,
  });

  Map<String, dynamic> toJson() => {
        'affectedRadius': affectedRadius,
        'affectedPopulation': affectedPopulation,
        'expectedDuration': expectedDuration,
        'peakImpactTime': peakImpactTime,
        'spreadRisk': spreadRisk,
        'uncertaintyRange': uncertaintyRange,
      };
}

class ResourceDecision {
  final String resource;
  final String assignedTo;
  final int priorityScore;
  final String reason;
  final String tradeOff;

  const ResourceDecision({
    required this.resource,
    required this.assignedTo,
    required this.priorityScore,
    required this.reason,
    required this.tradeOff,
  });

  Map<String, dynamic> toJson() => {
        'resource': resource,
        'assignedTo': assignedTo,
        'priorityScore': priorityScore,
        'reason': reason,
        'tradeOff': tradeOff,
      };
}

class StakeholderNotification {
  final String stakeholder;
  final String channel;
  final String message;
  final String urgency;

  const StakeholderNotification({
    required this.stakeholder,
    required this.channel,
    required this.message,
    required this.urgency,
  });

  Map<String, dynamic> toJson() => {
        'stakeholder': stakeholder,
        'channel': channel,
        'urgency': urgency,
        'message': message,
      };
}

class RelatedIncident {
  final String title;
  final CrisisType type;
  final String location;
  final SeverityLevel severity;
  final int affectedPopulation;
  final double confidence;
  final String coordinationNeed;

  const RelatedIncident({
    required this.title,
    required this.type,
    required this.location,
    required this.severity,
    required this.affectedPopulation,
    required this.confidence,
    required this.coordinationNeed,
  });
}

class MultiCrisisCoordination {
  final bool isActive;
  final String summary;
  final List<RelatedIncident> relatedIncidents;
  final List<String> tradeOffs;

  const MultiCrisisCoordination({
    required this.isActive,
    required this.summary,
    this.relatedIncidents = const [],
    this.tradeOffs = const [],
  });

  Map<String, dynamic> toJson() => {
        'isActive': isActive,
        'summary': summary,
        'relatedIncidents': relatedIncidents
            .map((i) => {
                  'title': i.title,
                  'type': i.type.name,
                  'location': i.location,
                  'severity': i.severity.name,
                  'affectedPopulation': i.affectedPopulation,
                  'confidence': i.confidence,
                  'coordinationNeed': i.coordinationNeed,
                })
            .toList(),
        'tradeOffs': tradeOffs,
      };
}

class AntigravityTraceEvent {
  final int step;
  final String agent;
  final String action;
  final String input;
  final String output;
  final double confidence;
  final String evidence;
  final Map<String, dynamic> metadata;

  const AntigravityTraceEvent({
    required this.step,
    required this.agent,
    required this.action,
    required this.input,
    required this.output,
    required this.confidence,
    required this.evidence,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'step': step,
        'agent': agent,
        'action': action,
        'input': input,
        'output': output,
        'confidence': confidence,
        'evidence': evidence,
        'metadata': metadata,
      };
}

class ScenarioOrchestrationHints {
  final String resourceConstraint;
  final String affectedRadius;
  final String peakImpactTime;
  final String spreadRisk;
  final String uncertaintyRange;
  final List<RelatedIncident> relatedIncidents;
  final List<String> resourceTradeOffs;
  final Map<String, String> stakeholderMessages;
  final String fallbackMode;

  const ScenarioOrchestrationHints({
    this.resourceConstraint = 'Local response resources available within normal operating limits.',
    this.affectedRadius = '1.5 km',
    this.peakImpactTime = '30-60 min',
    this.spreadRisk = 'Moderate without intervention',
    this.uncertaintyRange = '+/- 12%',
    this.relatedIncidents = const [],
    this.resourceTradeOffs = const [],
    this.stakeholderMessages = const {},
    this.fallbackMode = 'Mock-first deterministic scenario. Real APIs optional.',
  });
}
