import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/malta_data.dart';
import '../data/route_logic.dart';
import '../models/carpool_pool.dart';
import '../models/monthly_membership.dart';
import '../models/trip_category.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import 'find_pool_screen.dart';
import 'commute_recommendations_screen.dart';
import 'pool_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color indigoBlue = Color(0xFF3F51B5);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final rideProvider = context.watch<RideProvider>();
    final currentUserEmail = userProvider.userEmail ?? '';
    final activePool = rideProvider.getActivePoolForUser(currentUserEmail);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoCampus Dashboard'),
        backgroundColor: indigoBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Timetable matches',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CommuteRecommendationsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: userProvider.logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _RegionToggle(userProvider: userProvider),
          _MembershipCard(userProvider: userProvider),
          Expanded(
            child: activePool != null
                ? _ActiveRideDashboard(pool: activePool)
                : _DiscoveryFeed(
                    rideProvider: rideProvider,
                    userProvider: userProvider,
                  ),
          ),
        ],
      ),
      floatingActionButton: activePool == null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FindPoolScreen()),
              ),
              label: const Text('Find Pool'),
              icon: const Icon(Icons.search),
              backgroundColor: indigoBlue,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.userProvider});

  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hasCurrentMembership = userProvider.hasMembershipFor(now);
    final price = MonthlyMembership.priceFor(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        child: ListTile(
          leading: Icon(
            hasCurrentMembership ? Icons.verified : Icons.card_membership,
            color: HomeScreen.indigoBlue,
          ),
          title: Text(
            hasCurrentMembership ? 'Monthly Membership Active' : 'Monthly Membership',
          ),
          subtitle: Text(
            hasCurrentMembership
                ? 'No GoCampus ride fees this month.'
                : 'Skip ride fees this month for EUR ${price.toStringAsFixed(2)}.',
          ),
          trailing: hasCurrentMembership
              ? null
              : FilledButton(
                  onPressed: () => userProvider.buyMembershipFor(now),
                  child: const Text('Buy'),
                ),
        ),
      ),
    );
  }
}

class _RegionToggle extends StatelessWidget {
  const _RegionToggle({required this.userProvider});

  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<Region>(
        segments: const [
          ButtonSegment(
            value: Region.malta,
            label: Text('Malta'),
            icon: Icon(Icons.location_on_outlined),
          ),
          ButtonSegment(
            value: Region.gozo,
            label: Text('Gozo'),
            icon: Icon(Icons.directions_boat_outlined),
          ),
        ],
        selected: {userProvider.selectedRegion},
        onSelectionChanged: (selection) {
          userProvider.setRegion(selection.first);
        },
      ),
    );
  }
}

class _ActiveRideDashboard extends StatelessWidget {
  const _ActiveRideDashboard({required this.pool});

  final CarpoolPool pool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 100, color: HomeScreen.indigoBlue),
          const SizedBox(height: 24),
          const Text(
            'You have an active carpool!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '${pool.tripCategory.label}: ${DateFormat('E, MMM d - h:mm a').format(pool.departureTime)}',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Text(
                '${pool.originLocality.name} to ${pool.destination.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('Current Status: ${pool.status.name.toUpperCase()}'),
              trailing: const Icon(Icons.arrow_forward_ios, color: HomeScreen.indigoBlue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PoolDetailScreen(pool: pool)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tap the card above to manage pickup details or see your fellow passengers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryFeed extends StatelessWidget {
  const _DiscoveryFeed({
    required this.rideProvider,
    required this.userProvider,
  });

  final RideProvider rideProvider;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final filteredPools = rideProvider.allPools
        .where((pool) => pool.region == userProvider.selectedRegion)
        .toList();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _PopularDestinations()),
        const SliverToBoxAdapter(child: _SponsoredStudentOfferCard()),
        if (filteredPools.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.car_repair_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No pools found in ${userProvider.selectedRegion == Region.malta ? 'Malta' : 'Gozo'}.',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Text('Be the first to start one!'),
                ],
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: filteredPools.length,
            itemBuilder: (context, index) {
              return _PoolTile(pool: filteredPools[index]);
            },
          ),
      ],
    );
  }
}

class _SponsoredStudentOfferCard extends StatelessWidget {
  const _SponsoredStudentOfferCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer_outlined, color: Color(0xFFF57C00)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sponsored Student Offer',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Student Deal Placeholder',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Limited campus, event, or summer partner offer.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularDestinations extends StatelessWidget {
  const _PopularDestinations();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Events and Summer Spots',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: summerStudentDestinations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _DestinationCard(
                  destination: summerStudentDestinations[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});

  final StudentDestination destination;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Card(
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FindPoolScreen(
                initialDestinationName: destination.name,
                initialCategory: destination.category,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_destinationIcon(destination.type), color: HomeScreen.indigoBlue),
                const SizedBox(height: 8),
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  destination.category.shortLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _destinationIcon(StudentDestinationType type) {
    return switch (type) {
      StudentDestinationType.campus => Icons.school,
      StudentDestinationType.beach => Icons.beach_access,
      StudentDestinationType.nightlife => Icons.nightlife,
      StudentDestinationType.city => Icons.location_city,
      StudentDestinationType.event => Icons.event,
    };
  }
}

class _PoolTile extends StatelessWidget {
  const _PoolTile({required this.pool});

  final CarpoolPool pool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PoolDetailScreen(pool: pool)),
          ),
          leading: CircleAvatar(
            backgroundColor: HomeScreen.indigoBlue.withValues(alpha: 0.1),
            child: const Icon(Icons.group, color: HomeScreen.indigoBlue),
          ),
          title: Text('${pool.originLocality.name} to ${pool.destination.name}'),
          subtitle: Text(
            '${pool.tripCategory.shortLabel}: ${DateFormat('E, MMM d - h:mm a').format(pool.departureTime)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16, color: HomeScreen.indigoBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${pool.studentEmails.length}/4',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Text(
                'JOINED',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
