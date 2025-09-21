import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/points_provider.dart';
import '../models/points.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Points'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<PointsProvider>(
        builder: (context, pointsProvider, child) {
          final userPoints = pointsProvider.userPoints;

          if (pointsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userPoints == null) {
            return const Center(child: Text('No points data available'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(userPoints, pointsProvider),
              _buildHistoryTab(userPoints, pointsProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(
    UserPoints userPoints,
    PointsProvider pointsProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level and Points Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  pointsProvider.getLevelColor(userPoints.level),
                  pointsProvider
                      .getLevelColor(userPoints.level)
                      .withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: pointsProvider
                      .getLevelColor(userPoints.level)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      pointsProvider.getLevelIcon(userPoints.level),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${userPoints.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userPoints.levelTitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            NumberFormat(
                              '#,###',
                            ).format(userPoints.totalPoints),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Total Points',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white30),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            NumberFormat(
                              '#,###',
                            ).format(userPoints.pointsToNextLevel),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'To Next Level',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress to Next Level',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: userPoints.levelProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Points Breakdown
          Text(
            'Points Breakdown',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildPointsBreakdown(userPoints),

          const SizedBox(height: 24),

          // Recent Activity
          Row(
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildRecentActivity(userPoints.recentEntries.take(3).toList()),
        ],
      ),
    );
  }

  Widget _buildPointsBreakdown(UserPoints userPoints) {
    final pointsByType = userPoints.pointsByType;

    if (pointsByType.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No points earned yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: pointsByType.entries.map((entry) {
          final pointType = entry.key;
          final points = entry.value;
          final config =
              PointsConfig.descriptions[pointType] ?? 'Points earned';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                _getPointTypeIcon(pointType),
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            title: Text(config),
            trailing: Text(
              '+${NumberFormat('#,###').format(points)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryTab(
    UserPoints userPoints,
    PointsProvider pointsProvider,
  ) {
    return FutureBuilder<List<PointsEntry>>(
      future: pointsProvider.getPointsHistory(userPoints.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No points history yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start exploring and earning points!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final history = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index];
            return _buildHistoryItem(entry);
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(List<PointsEntry> recentEntries) {
    if (recentEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: recentEntries
            .map((entry) => _buildHistoryItem(entry))
            .toList(),
      ),
    );
  }

  Widget _buildHistoryItem(PointsEntry entry) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(
          _getPointTypeIcon(entry.type),
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(entry.description),
      subtitle: Text(dateFormat.format(entry.dateEarned)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+${entry.points}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  IconData _getPointTypeIcon(PointType pointType) {
    switch (pointType) {
      case PointType.tripCreated:
        return Icons.add_location;
      case PointType.tripCompleted:
        return Icons.check_circle;
      case PointType.memoryAdded:
        return Icons.photo_camera;
      case PointType.placeVisited:
        return Icons.place;
      case PointType.photosUploaded:
        return Icons.photo;
      case PointType.milestoneReached:
        return Icons.emoji_events;
      case PointType.dailyLogin:
        return Icons.login;
      case PointType.profileCompleted:
        return Icons.person;
    }
  }
}
