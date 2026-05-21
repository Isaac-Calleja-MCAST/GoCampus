import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student_profile.dart';
import '../models/timetable_entry.dart';
import '../data/route_logic.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import 'timetable_import_screen.dart';

class CommuteRecommendationsScreen extends StatelessWidget {
  CommuteRecommendationsScreen({super.key});

  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentProfile = userProvider.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Matches'),
        actions: [
          IconButton(
            tooltip: 'Import timetable',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TimetableImportScreen()),
            ),
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: currentProfile == null
          ? const Center(child: Text('Complete your student profile first.'))
          : StreamBuilder<List<StudentProfile>>(
              stream: _firestore.getProfilesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Recommendations are unavailable right now.'));
                }

                final matches = _recommendations(
                  currentProfile,
                  snapshot.data ?? const [],
                );
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ImportedTimetableSummary(profile: currentProfile),
                    const SizedBox(height: 16),
                    if (currentProfile.timetable.isEmpty)
                      _ImportPrompt(
                        onImport: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TimetableImportScreen(),
                          ),
                        ),
                      )
                    else if (matches.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'No matching commuters yet. Import timetables for demo students to show recommendations.',
                          ),
                        ),
                      )
                    else
                      ...matches.map((match) => _RecommendationTile(match: match)),
                  ],
                );
              },
            ),
    );
  }

  List<_ProfileMatch> _recommendations(
    StudentProfile currentProfile,
    List<StudentProfile> profiles,
  ) {
    return profiles
        .where((profile) =>
            profile.email != currentProfile.email &&
            profile.homeTown == currentProfile.homeTown &&
            profile.campus == currentProfile.campus)
        .map((profile) {
          final sharedStarts = _sharedStarts(
            currentProfile.timetable,
            profile.timetable,
          );
          return _ProfileMatch(profile: profile, sharedStarts: sharedStarts);
        })
        .where((match) => match.sharedStarts.isNotEmpty)
        .toList(growable: false);
  }

  List<TimetableEntry> _sharedStarts(
    List<TimetableEntry> first,
    List<TimetableEntry> second,
  ) {
    return first
        .where((entry) => second.any(entry.startsWith))
        .toList(growable: false);
  }
}

class _ImportedTimetableSummary extends StatelessWidget {
  const _ImportedTimetableSummary({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${profile.displayName} commute profile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${profile.homeTown.name} to ${profile.campus}'),
            const SizedBox(height: 10),
            if (profile.timetable.isEmpty)
              const Text('No timetable starts imported yet.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.timetable
                    .map((entry) => Chip(label: Text(entry.label)))
                    .toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImportPrompt extends StatelessWidget {
  const _ImportPrompt({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import a timetable to unlock recommendations.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Timetable'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.match});

  final _ProfileMatch match;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(match.profile.displayName),
        subtitle: Text(
          'Matches ${match.sharedStarts.map((entry) => entry.label).join(', ')}',
        ),
      ),
    );
  }
}

class _ProfileMatch {
  const _ProfileMatch({
    required this.profile,
    required this.sharedStarts,
  });

  final StudentProfile profile;
  final List<TimetableEntry> sharedStarts;
}
