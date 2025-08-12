import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:notifoo/src/util/glow.dart';
import 'package:notifoo/src/services/app_usage_service.dart';
import 'package:notifoo/src/model/apps.dart';
import 'package:notifoo/src/model/app_block_schedule.dart';
import 'package:notifoo/src/model/usage_analytics.dart';

class AppUsagePage extends StatefulWidget {
  const AppUsagePage({Key? key}) : super(key: key);

  @override
  State<AppUsagePage> createState() => _AppUsagePageState();
}

class _AppUsagePageState extends State<AppUsagePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AppUsageService _usageService;
  bool _loading = true;
  bool _hasPermission = false;
  
  // Analytics data
  UsageAnalytics? _todayAnalytics;
  WeeklyAnalytics? _weeklyAnalytics;
  
  // App data
  List<Apps> _installedApps = [];
  List<Apps> _userApps = [];
  List<AppBlockSchedule> _blockSchedules = [];
  
  // UI state
  List<String> _selectedCategories = [];
  int _blockDurationMinutes = 60;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _usageService = AppUsageService();
    _init();
  }

  Future<void> _init() async {
    if (!Platform.isAndroid) {
      setState(() { _loading = false; });
      return;
    }
    
    try {
      await _usageService.initialize();
      _hasPermission = _usageService.hasPermission;
      
      if (_hasPermission) {
        await _loadData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing: $e');
      }
    }
    
    setState(() { _loading = false; });
  }

  Future<void> _requestPermission() async {
    await _usageService.openPermissionSettings();
    await Future.delayed(const Duration(seconds: 1));
    final ok = await _usageService.hasUsagePermission();
    setState(() { _hasPermission = ok; });
    if (ok) {
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; });
    
    try {
      _todayAnalytics = _usageService.todayAnalytics;
      _weeklyAnalytics = _usageService.weeklyAnalytics;
      _installedApps = _usageService.installedApps;
      _userApps = _usageService.userApps;
      _blockSchedules = _usageService.blockSchedules;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading data: $e');
      }
    }
    
    setState(() { _loading = false; });
  }

  String _fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h <= 0) return '${m}m';
    return '${h}h ${m}m';
  }

  String _getDisplayName(Apps app) {
    // Prioritize app name over package name
    if (app.appName != null && app.appName!.isNotEmpty && app.appName != app.packageName) {
      return app.appName!;
    }
    
    // If no app name, try to make package name more readable
    if (app.packageName != null && app.packageName!.contains(".")) {
      final parts = app.packageName!.split(".");
      if (parts.isNotEmpty) {
        final lastPart = parts.last;
        if (lastPart.isNotEmpty) {
          return lastPart[0].toUpperCase() + lastPart.substring(1);
        }
      }
    }
    
    return app.packageName ?? 'Unknown App';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Usage Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.show_chart), text: 'Analytics'),
            Tab(icon: Icon(Icons.block), text: 'Blocking'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedules'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(theme, cs),
                _buildAnalyticsTab(theme, cs),
                _buildBlockingTab(theme, cs),
                _buildSchedulesTab(theme, cs),
              ],
            ),
    );
  }

  // Today Tab
  Widget _buildTodayTab(ThemeData theme, ColorScheme cs) {
    if (_todayAnalytics == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPISummary(theme, cs),
          const SizedBox(height: 20),
          _buildHourlyChart(theme, cs),
          const SizedBox(height: 20),
          _buildMostUsedApps(theme, cs),
          const SizedBox(height: 20),
          _buildBlockNowButton(theme, cs),
        ],
      ),
    );
  }

  Widget _buildKPISummary(ThemeData theme, ColorScheme cs) {
    final analytics = _todayAnalytics!;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: cs.primary.withOpacity(0.25), blurRadius: 24, spreadRadius: 2),
        ],
        gradient: LinearGradient(
          colors: [cs.primary.withOpacity(0.20), cs.secondary.withOpacity(0.20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 350) {
                  // Wide layout - side by side
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SCREEN TIME TODAY', 
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.1, 
                                  color: cs.onSurface.withOpacity(0.6)
                                )),
                            const SizedBox(height: 8),
                            Text(_fmtMinutes(analytics.totalScreenTimeMinutes), 
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800, 
                                  color: cs.onSurface
                                )),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('FOCUS SCORE', 
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.1, 
                                color: cs.onSurface.withOpacity(0.6)
                              )),
                          const SizedBox(height: 8),
                          Text('${(analytics.focusScore * 100).toInt()}%', 
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800, 
                                  color: _getFocusScoreColor(analytics.focusScore)
                                )),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Narrow layout - stacked
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SCREEN TIME TODAY', 
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1, 
                            color: cs.onSurface.withOpacity(0.6)
                          )),
                      const SizedBox(height: 8),
                      Text(_fmtMinutes(analytics.totalScreenTimeMinutes), 
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800, 
                            color: cs.onSurface
                          )),
                      const SizedBox(height: 16),
                      Text('FOCUS SCORE', 
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1, 
                            color: cs.onSurface.withOpacity(0.6)
                          )),
                      const SizedBox(height: 8),
                      Text('${(analytics.focusScore * 100).toInt()}%', 
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800, 
                              color: _getFocusScoreColor(analytics.focusScore)
                            )),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 300) {
                  // Wide layout - side by side
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PICKUPS', 
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.1, 
                                  color: cs.onSurface.withOpacity(0.6)
                                )),
                            const SizedBox(height: 8),
                            Text('${analytics.totalPickups}', 
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800, 
                                  color: cs.onSurface
                                )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('APP LAUNCHES', 
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.1, 
                                  color: cs.onSurface.withOpacity(0.6)
                                )),
                            const SizedBox(height: 8),
                            Text('${analytics.totalAppLaunches}', 
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800, 
                                  color: cs.onSurface
                                )),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout - stacked
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PICKUPS', 
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1, 
                            color: cs.onSurface.withOpacity(0.6)
                          )),
                      const SizedBox(height: 8),
                      Text('${analytics.totalPickups}', 
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800, 
                            color: cs.onSurface
                          )),
                      const SizedBox(height: 16),
                      Text('APP LAUNCHES', 
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1, 
                            color: cs.onSurface.withOpacity(0.6)
                          )),
                      const SizedBox(height: 8),
                      Text('${analytics.totalAppLaunches}', 
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800, 
                            color: cs.onSurface
                          )),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(ThemeData theme, ColorScheme cs) {
    final hourlyData = _todayAnalytics?.getHourlyBreakdown() ?? List<int>.filled(24, 0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hourly Activity', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 24 * 24.0, // 24 hours * 24px width
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (i) {
                  final value = i < hourlyData.length ? hourlyData[i] : 0;
                  final maxValue = hourlyData.isNotEmpty ? hourlyData.reduce((a, b) => a > b ? a : b) : 1;
                  final height = maxValue > 0 ? (value / maxValue) * 80 + 8 : 8;
                  
                  return Container(
                    width: 22, // Slightly reduced width for better spacing
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      children: [
                        Container(
                          height: height.toDouble(),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary.withOpacity(0.85), cs.primary.withOpacity(0.55)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.25),
                                blurRadius: 6,
                                spreadRadius: 0,
                                offset: const Offset(0, 3)
                              ),
                            ],
                          ),
                        ),
                        if (i % 3 == 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${i.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMostUsedApps(ThemeData theme, ColorScheme cs) {
    final topApps = _todayAnalytics?.getTopAppsByUsage().take(10).toList() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Most Used Apps', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Column(
          children: topApps.map((entry) {
            final app = _userApps.firstWhere(
              (a) => a.packageName == entry.key,
              orElse: () => Apps(packageName: entry.key, appType: 'Neutral'),
            );
            
            return Glows.wrapGlow(
              color: _getCategoryColor(app.appType ?? 'Neutral'),
              blur: 12,
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(app.appType ?? 'Neutral').withOpacity(0.15),
                    child: _AppIconFromBase64(base64: app.iconBase64),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getDisplayName(app),
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(app.appType ?? 'Neutral').withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          app.appType ?? 'Neutral',
                          style: TextStyle(
                            color: _getCategoryColor(app.appType ?? 'Neutral'),
                            fontSize: 11,
                            fontWeight: FontWeight.w600
                          )
                        ),
                      ),
                      if (app.isBlocked == true) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.block, color: Colors.red, size: 16),
                      ],
                    ],
                  ),
                  trailing: Text(
                    _fmtMinutes(entry.value),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface
                    )
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBlockNowButton(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _blockSelectedCategories,
          icon: const Icon(Icons.block),
          label: const Text('Block Apps Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),
    );
  }

  // Analytics Tab
  Widget _buildAnalyticsTab(ThemeData theme, ColorScheme cs) {
    if (_todayAnalytics == null || _weeklyAnalytics == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No analytics data available', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Complete some activities to see your analytics', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsSummary(theme, cs),
          const SizedBox(height: 20),
          _buildWeeklyChart(theme, cs),
          const SizedBox(height: 20),
          _buildCategoryBreakdown(theme, cs),
          const SizedBox(height: 20),
          _buildProductivityScore(theme, cs),
          const SizedBox(height: 20),
          _buildUsageTrends(theme, cs),
          const SizedBox(height: 20),
          _buildAppInsights(theme, cs),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSummary(ThemeData theme, ColorScheme cs) {
    final today = _todayAnalytics;
    final weekly = _weeklyAnalytics;
    
    if (today == null || weekly == null) {
      return Container();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics Overview', 
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800, 
                color: cs.onSurface
              )),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout based on available width
              if (constraints.maxWidth > 600) {
                // Wide layout - side by side with creative right side
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                              theme, cs,
                              icon: Icons.today,
                              title: 'Today',
                              value: _fmtMinutes(today.totalScreenTimeMinutes),
                              subtitle: '${today.totalPickups} pickups',
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAnalyticsCard(
                              theme, cs,
                              icon: Icons.show_chart,
                              title: 'This Week',
                              value: _fmtMinutes(weekly.getTotalScreenTime()),
                              subtitle: '${weekly.getTotalPickups()} pickups',
                              color: cs.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: _buildCreativeRightSide(theme, cs, today, weekly),
                    ),
                  ],
                );
              } else if (constraints.maxWidth > 400) {
                // Medium layout - side by side
                return Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsCard(
                        theme, cs,
                        icon: Icons.today,
                        title: 'Today',
                        value: _fmtMinutes(today.totalScreenTimeMinutes),
                        subtitle: '${today.totalPickups} pickups',
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalyticsCard(
                        theme, cs,
                        icon: Icons.show_chart,
                        title: 'This Week',
                        value: _fmtMinutes(weekly.getTotalScreenTime()),
                        subtitle: '${weekly.getTotalPickups()} pickups',
                        color: cs.secondary,
                      ),
                    ),
                  ],
                );
              } else {
                // Narrow layout - stacked
                return Column(
                  children: [
                    _buildAnalyticsCard(
                      theme, cs,
                      icon: Icons.today,
                      title: 'Today',
                      value: _fmtMinutes(today.totalScreenTimeMinutes),
                      subtitle: '${today.totalPickups} pickups',
                      color: cs.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      theme, cs,
                      icon: Icons.show_chart,
                      title: 'This Week',
                      value: _fmtMinutes(weekly.getTotalScreenTime()),
                      subtitle: '${weekly.getTotalPickups()} pickups',
                      color: cs.secondary,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(ThemeData theme, ColorScheme cs, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title, 
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value, 
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeRightSide(ThemeData theme, ColorScheme cs, UsageAnalytics today, WeeklyAnalytics weekly) {
    final totalTime = today.totalScreenTimeMinutes + weekly.getTotalScreenTime();
    final productivityScore = _calculateProductivityScore(today, weekly);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.1),
            cs.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Productivity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$productivityScore%',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getProductivityStatus(productivityScore),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateProductivityScore(UsageAnalytics today, WeeklyAnalytics weekly) {
    final totalTime = today.totalScreenTimeMinutes + weekly.getTotalScreenTime();
    final totalPickups = today.totalPickups + weekly.getTotalPickups();
    
    if (totalTime == 0) return 0;
    
    // Base score from screen time (max 60%)
    final timeScore = (totalTime / (24 * 60)) * 60; // 24 hours max
    
    // Pickup efficiency score (max 40%)
    final pickupScore = totalPickups > 0 ? (totalTime / totalPickups) / 10 * 40 : 0;
    
    return ((timeScore + pickupScore) * 100).round().clamp(0, 100);
  }

  String _getProductivityStatus(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Focus';
  }

  Widget _buildWeeklyChart(ThemeData theme, ColorScheme cs) {
    final weeklyData = _weeklyAnalytics?.getDailyBreakdown() ?? List<int>.filled(7, 0);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This Week', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.2)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 32; // Account for padding
              final barWidth = (availableWidth / 7) - 4; // 7 days with spacing
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (i) {
                  final value = i < weeklyData.length ? weeklyData[i] : 0;
                  final maxValue = weeklyData.isNotEmpty ? weeklyData.reduce((a, b) => a > b ? a : b) : 1;
                  final height = maxValue > 0 ? (value / maxValue) * 100 + 8 : 8;
                  
                  return Container(
                    width: barWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.toDouble(),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary.withOpacity(0.85), cs.primary.withOpacity(0.55)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.25),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 4)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _fmtMinutes(value),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.8),
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsageTrends(ThemeData theme, ColorScheme cs) {
    final today = _todayAnalytics;
    if (today == null) return Container();
    
    final topApps = today.getTopAppsByUsage().take(5).toList();
    final topCategories = today.getTopCategoriesByUsage().take(5).toList();
    
    // Filter out system apps from top apps
    final userTopApps = topApps.where((entry) {
      final app = _userApps.firstWhere(
        (a) => a.packageName == entry.key,
        orElse: () => Apps(packageName: entry.key, appType: 'Neutral'),
      );
      return !_isSystemApp(app);
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Usage Trends', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout based on available width
            if (constraints.maxWidth > 500) {
              // Wide layout - side by side
              return Row(
                children: [
                  Expanded(
                    child: _buildTrendsCard(
                      theme, cs,
                      title: 'Top Apps',
                      items: topApps.map((e) => MapEntry(e.key, e.value)).toList(),
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTrendsCard(
                      theme, cs,
                      title: 'Top Categories',
                      items: topCategories.map((e) => MapEntry(e.key, e.value)).toList(),
                      color: cs.secondary,
                    ),
                  ),
                ],
              );
            } else {
              // Narrow layout - stacked
              return Column(
                children: [
                  _buildTrendsCard(
                    theme, cs,
                    title: 'Top Apps',
                    items: topApps.map((e) => MapEntry(e.key, e.value)).toList(),
                    color: cs.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildTrendsCard(
                    theme, cs,
                    title: 'Top Categories',
                    items: topCategories.map((e) => MapEntry(e.key, e.value)).toList(),
                    color: cs.secondary,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTrendsCard(ThemeData theme, ColorScheme cs, {
    required String title,
    required List<MapEntry<String, int>> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, 
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              )),
          const SizedBox(height: 12),
          ...items.map((item) {
            final percentage = items.isNotEmpty ? (item.value / items.first.value * 100).toInt() : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: item.value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: items.first.value - item.value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.outline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      _fmtMinutes(item.value),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme, ColorScheme cs) {
    final categoryData = _todayAnalytics?.getTopCategoriesByUsage() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Breakdown', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Column(
          children: categoryData.map((entry) {
            final totalMinutes = _todayAnalytics?.totalScreenTimeMinutes ?? 1;
            final percentage = (entry.value / totalMinutes * 100).toInt();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600
                        )
                      )
                    ),
                    Text(
                      '${_fmtMinutes(entry.value)} ($percentage%)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.7)
                      )
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductivityScore(ThemeData theme, ColorScheme cs) {
    final productivityScore = _todayAnalytics?.getProductivityScore() ?? 0.5;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Productivity Score', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getProductivityColor(productivityScore).withOpacity(0.1),
                _getProductivityColor(productivityScore).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getProductivityColor(productivityScore).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getProductivityColor(productivityScore).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Score Circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getProductivityColor(productivityScore),
                      _getProductivityColor(productivityScore).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getProductivityColor(productivityScore).withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(productivityScore * 100).toInt()}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                      Text(
                        '%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Label
              Text(
                _getProductivityLabel(productivityScore),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _getProductivityColor(productivityScore),
                ),
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                _getProductivityDescription(productivityScore),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distracted',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Focused',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (productivityScore * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getProductivityColor(productivityScore),
                                  _getProductivityColor(productivityScore).withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 100 - (productivityScore * 100).toInt(),
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Blocking Tab
  Widget _buildBlockingTab(ThemeData theme, ColorScheme cs) {
    final blockedApps = _usageService.getCurrentlyBlockedApps();
    final categories = _usageService.getAllCategories();
    
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Permission Required', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Grant usage access permission to block apps', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickBlockSection(theme, cs, categories),
          const SizedBox(height: 20),
          if (blockedApps.isNotEmpty) ...[
            _buildBlockedAppsSection(theme, cs, blockedApps),
            const SizedBox(height: 20),
          ],
          _buildAppCategoriesSection(theme, cs, categories),
          const SizedBox(height: 20),
          _buildBlockingStats(theme, cs),
        ],
      ),
    );
  }

  Widget _buildQuickBlockSection(ThemeData theme, ColorScheme cs, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Block', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text('Select categories to block:', 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.7)
                  )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                    selectedColor: cs.primary.withOpacity(0.2),
                    checkmarkColor: cs.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 300) {
                    // Wide layout - side by side
                    return Row(
                      children: [
                        Text('Duration: ', 
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.7)
                            )),
                        Expanded(
                          child: Slider(
                            value: _blockDurationMinutes.toDouble(),
                            min: 15,
                            max: 480, // 8 hours
                            divisions: 31,
                            label: _fmtMinutes(_blockDurationMinutes),
                            onChanged: (value) {
                              setState(() {
                                _blockDurationMinutes = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(_fmtMinutes(_blockDurationMinutes)),
                      ],
                    );
                  } else {
                    // Narrow layout - stacked
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duration: ', 
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.7)
                            )),
                        Slider(
                          value: _blockDurationMinutes.toDouble(),
                          min: 15,
                          max: 480, // 8 hours
                          divisions: 31,
                          label: _fmtMinutes(_blockDurationMinutes),
                          onChanged: (value) {
                            setState(() {
                              _blockDurationMinutes = value.toInt();
                            });
                          },
                        ),
                        Text(_fmtMinutes(_blockDurationMinutes)),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedCategories.isEmpty ? null : _blockSelectedCategories,
                  icon: const Icon(Icons.block),
                  label: Text('Block for ${_fmtMinutes(_blockDurationMinutes)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedAppsSection(ThemeData theme, ColorScheme cs, List<Apps> blockedApps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Currently Blocked', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Column(
          children: blockedApps.map((app) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.15),
                  child: _AppIconFromBase64(base64: app.iconBase64),
                ),
                title: Text(app.appName ?? app.packageName ?? 'Unknown App'),
                subtitle: Text(app.appType ?? 'Neutral'),
                trailing: ElevatedButton(
                  onPressed: () => _unblockApp(app),
                  child: const Text('Unblock'),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAppCategoriesSection(ThemeData theme, ColorScheme cs, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Categories', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Column(
          children: categories.map((category) {
            final appsInCategory = _usageService.getAppsByCategory(category);
            final userAppsInCategory = appsInCategory.where((app) => !_isSystemApp(app)).toList();
            final totalMinutes = userAppsInCategory.fold<int>(
              0, (sum, app) => sum + (app.dailyUsageMinutes ?? 0)
            );
            
            if (userAppsInCategory.isEmpty) return Container();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(category).withOpacity(0.15),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                  ),
                ),
                title: Text(category),
                subtitle: Text('${userAppsInCategory.length} user apps • ${_fmtMinutes(totalMinutes)} today'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_fmtMinutes(totalMinutes)}', 
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.7)
                        )),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _blockCategory(category),
                      icon: const Icon(Icons.block, color: Colors.red),
                      tooltip: 'Block all apps in this category',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBlockingStats(ThemeData theme, ColorScheme cs) {
    final blockedApps = _usageService.getCurrentlyBlockedApps();
    final totalUserApps = _userApps.length;
    final blockedCount = blockedApps.length;
    final blockedPercentage = totalUserApps > 0 ? (blockedCount / totalUserApps * 100).toInt() : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.1), Colors.orange.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Text('Blocking Statistics', 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, 
                    color: cs.onSurface
                  )),
            ],
          ),
          const SizedBox(height: 16),
                    LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 350) {
                // Always show side by side for better space utilization
                return Row(
                  children: [
                    Expanded(
                      child: _buildBlockingStatCard(
                        theme, cs,
                        title: 'Total User Apps',
                        value: '$totalUserApps',
                        icon: Icons.apps,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBlockingStatCard(
                        theme, cs,
                        title: 'Currently Blocked',
                        value: '$blockedCount',
                        icon: Icons.block,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBlockingStatCard(
                        theme, cs,
                        title: 'Blocked %',
                        value: '$blockedPercentage%',
                        icon: Icons.percent,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              } else {
                // Only stack for very narrow screens
                return Column(
                  children: [
                    _buildBlockingStatCard(
                      theme, cs,
                      title: 'Total User Apps',
                      value: '$totalUserApps',
                      icon: Icons.apps,
                      color: cs.primary,
                      ),
                    const SizedBox(height: 12),
                    _buildBlockingStatCard(
                      theme, cs,
                      title: 'Currently Blocked',
                      value: '$blockedCount',
                      icon: Icons.block,
                      color: Colors.red,
                      ),
                    const SizedBox(height: 12),
                    _buildBlockingStatCard(
                      theme, cs,
                      title: 'Blocked %',
                      value: '$blockedPercentage%',
                      icon: Icons.percent,
                      color: Colors.orange,
                      ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlockingStatCard(ThemeData theme, ColorScheme cs, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value, 
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title, 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Schedules Tab
  Widget _buildSchedulesTab(ThemeData theme, ColorScheme cs) {
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Permission Required', style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Grant usage access permission to manage schedules', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScheduleHeader(theme, cs),
          const SizedBox(height: 20),
          _buildActiveSchedulesSection(theme, cs),
          const SizedBox(height: 20),
          _buildAllSchedulesSection(theme, cs),
          const SizedBox(height: 20),
          _buildQuickScheduleTemplates(theme, cs),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddScheduleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add New Schedule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHeader(ThemeData theme, ColorScheme cs) {
    final totalSchedules = _blockSchedules.length;
    final activeSchedules = _blockSchedules.where((s) => s.isCurrentlyActive).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withOpacity(0.1), cs.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: cs.primary, size: 24),
              const SizedBox(width: 12),
              Text('Schedule Management', 
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, 
                    color: cs.onSurface
                  )),
            ],
          ),
          const SizedBox(height: 16),
                    LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 300) {
                // Always show side by side for better space utilization
                return Row(
                  children: [
                    Expanded(
                      child: _buildScheduleStatCard(
                        theme, cs,
                        title: 'Total Schedules',
                        value: '$totalSchedules',
                        icon: Icons.list,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildScheduleStatCard(
                        theme, cs,
                        title: 'Active Now',
                        value: '$activeSchedules',
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              } else {
                // Only stack for very narrow screens
                return Column(
                  children: [
                    _buildScheduleStatCard(
                      theme, cs,
                      title: 'Total Schedules',
                      value: '$totalSchedules',
                      icon: Icons.list,
                      color: cs.primary,
                      ),
                    const SizedBox(height: 16),
                    _buildScheduleStatCard(
                      theme, cs,
                        title: 'Active Now',
                        value: '$activeSchedules',
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStatCard(ThemeData theme, ColorScheme cs, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            value, 
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSchedulesSection(ThemeData theme, ColorScheme cs) {
    final activeSchedules = _blockSchedules.where((s) => s.isCurrentlyActive).toList();
    
    if (activeSchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.schedule, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text('No Active Schedules', 
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, 
                  color: Colors.grey
                )),
            const SizedBox(height: 8),
            Text('Create a schedule to start blocking apps automatically', 
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Now', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: Colors.green
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: activeSchedules.map((schedule) {
              return ListTile(
                leading: Icon(Icons.schedule, color: Colors.green),
                title: Text(schedule.name),
                subtitle: Text(schedule.description),
                trailing: Text(
                  '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green
                  )
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAllSchedulesSection(ThemeData theme, ColorScheme cs) {
    if (_blockSchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.schedule_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text('No Schedules Created', 
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, 
                  color: Colors.grey
                )),
            const SizedBox(height: 8),
            Text('Create your first schedule to start managing app blocking', 
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Schedules', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        Column(
          children: _blockSchedules.map((schedule) {
            final isActive = schedule.isCurrentlyActive;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive ? Colors.green.withOpacity(0.15) : cs.primary.withOpacity(0.15),
                  child: Icon(
                    isActive ? Icons.schedule : Icons.schedule_outlined,
                    color: isActive ? Colors.green : cs.primary,
                  ),
                ),
                title: Text(schedule.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.description),
                    Text(
                      '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6)
                      )
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: schedule.isActive,
                      onChanged: (value) => _toggleSchedule(schedule, value),
                    ),
                    IconButton(
                      onPressed: () => _editSchedule(schedule),
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickScheduleTemplates(ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Templates', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return Row(
                children: [
                  Expanded(
                    child: _buildTemplateCard(
                      theme, cs,
                      title: 'Focus Time',
                      description: 'Block distracting apps during work hours',
                      icon: Icons.work,
                      color: Colors.blue,
                      onTap: () => _createFocusTimeSchedule(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTemplateCard(
                      theme, cs,
                      title: 'Sleep Mode',
                      description: 'Block all apps during bedtime',
                      icon: Icons.bedtime,
                      color: Colors.indigo,
                      onTap: () => _createSleepModeSchedule(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTemplateCard(
                      theme, cs,
                      title: 'Study Session',
                      description: 'Block entertainment apps for studying',
                      icon: Icons.school,
                      color: Colors.green,
                      onTap: () => _createStudySchedule(),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildTemplateCard(
                    theme, cs,
                    title: 'Focus Time',
                    description: 'Block distracting apps during work hours',
                    icon: Icons.work,
                    color: Colors.blue,
                    onTap: () => _createFocusTimeSchedule(),
                  ),
                  const SizedBox(height: 16),
                  _buildTemplateCard(
                    theme, cs,
                    title: 'Sleep Mode',
                    description: 'Block all apps during bedtime',
                    icon: Icons.bedtime,
                    color: Colors.indigo,
                    onTap: () => _createSleepModeSchedule(),
                  ),
                  const SizedBox(height: 16),
                  _buildTemplateCard(
                    theme, cs,
                    title: 'Study Session',
                    description: 'Block entertainment apps for studying',
                    icon: Icons.school,
                    color: Colors.green,
                    onTap: () => _createStudySchedule(),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTemplateCard(ThemeData theme, ColorScheme cs, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, 
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, 
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.7)
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Tap to create', 
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600
                    )),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: color, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getFocusScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  // Check if app is system app (helper method)
  bool _isSystemApp(Apps app) {
    if (app.packageName == null) return true;
    
    final packageName = app.packageName!.toLowerCase();
    
    // Check if it's a system app based on package name characteristics
    if (packageName.contains('system') || 
        packageName.contains('android') ||
        packageName.contains('google') ||
        packageName.contains('qualcomm') ||
        packageName.contains('mediatek') ||
        packageName.contains('samsung') ||
        packageName.contains('huawei') ||
        packageName.contains('xiaomi') ||
        packageName.contains('oneplus') ||
        packageName.contains('oppo') ||
        packageName.contains('vivo') ||
        packageName.contains('realme') ||
        packageName.contains('iqoo') ||
        packageName.contains('meizu') ||
        packageName.contains('zte') ||
        packageName.contains('lenovo') ||
        packageName.contains('asus') ||
        packageName.contains('htc') ||
        packageName.contains('lg') ||
        packageName.contains('sony') ||
        packageName.contains('motorola') ||
        packageName.contains('nokia') ||
        packageName.contains('blackberry') ||
        packageName.contains('bbm') ||
        packageName.contains('rim') ||
        packageName.contains('acer') ||
        packageName.contains('alcatel') ||
        packageName.contains('bq') ||
        packageName.contains('coolpad') ||
        packageName.contains('gionee') ||
        packageName.contains('honor') ||
        packageName.contains('leeco') ||
        packageName.contains('letv') ||
        packageName.contains('meitu') ||
        packageName.contains('nubia')) {
      return true;
    }
    
    return false;
  }

  Widget _buildAppInsights(ThemeData theme, ColorScheme cs) {
    final today = _todayAnalytics;
    if (today == null) return Container();
    
    final totalScreenTime = today.totalScreenTimeMinutes;
    final totalPickups = today.totalPickups;
    final totalAppLaunches = today.totalAppLaunches;
    
    if (totalScreenTime == 0) return Container();
    
    final avgSessionTime = totalScreenTime / totalAppLaunches;
    final pickupFrequency = totalPickups > 0 ? totalScreenTime / totalPickups : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Insights', 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700, 
              color: cs.onSurface
            )),
        const SizedBox(height: 12),
                LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 300) {
              // Always show side by side for better space utilization
              return Row(
                children: [
                  Expanded(
                    child: _buildInsightCard(
                      theme, cs,
                      icon: Icons.timer,
                      title: 'Avg Session',
                      value: _fmtMinutes(avgSessionTime.toInt()),
                      subtitle: 'per app launch',
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInsightCard(
                      theme, cs,
                      icon: Icons.touch_app,
                      title: 'Pickup Rate',
                      value: pickupFrequency > 0 ? '${pickupFrequency.toInt()}m' : 'N/A',
                      subtitle: 'between pickups',
                      color: cs.secondary,
                    ),
                  ),
                ],
              );
            } else {
              // Only stack for very narrow screens
              return Column(
                children: [
                  _buildInsightCard(
                    theme, cs,
                    icon: Icons.timer,
                    title: 'Avg Session',
                    value: _fmtMinutes(avgSessionTime.toInt()),
                    subtitle: 'per app launch',
                    color: cs.primary,
                    ),
                  const SizedBox(height: 16),
                  _buildInsightCard(
                    theme, cs,
                    icon: Icons.touch_app,
                    title: 'Pickup Rate',
                    value: pickupFrequency > 0 ? '${pickupFrequency.toInt()}m' : 'N/A',
                    subtitle: 'between pickups',
                    color: cs.secondary,
                    ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildInsightCard(ThemeData theme, ColorScheme cs, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title, 
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value, 
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProductivityColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    if (score >= 0.4) return Colors.yellow;
    return Colors.red;
  }

  String _getProductivityLabel(double score) {
    if (score >= 0.8) return 'Highly Productive';
    if (score >= 0.6) return 'Productive';
    if (score >= 0.4) return 'Moderate';
    return 'Distracted';
  }

  String _getProductivityDescription(double score) {
    if (score >= 0.8) return 'You are highly productive and focused on your tasks.';
    if (score >= 0.6) return 'You are productive and have a good balance of work and leisure.';
    if (score >= 0.4) return 'You are moderately productive and might need to focus more.';
    return 'You are distracted and need to improve your focus.';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Productive':
      case 'Work':
      case 'Education':
        return Colors.green;
      case 'Distracting':
      case 'Social':
      case 'Entertainment':
        return Colors.red;
      case 'Gaming':
        return Colors.orange;
      case 'Health':
        return Colors.blue;
      case 'System':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Productive':
      case 'Work':
        return Icons.work;
      case 'Education':
        return Icons.school;
      case 'Social':
        return Icons.people;
      case 'Entertainment':
        return Icons.movie;
      case 'Gaming':
        return Icons.games;
      case 'Health':
        return Icons.favorite;
      case 'System':
        return Icons.settings;
      default:
        return Icons.apps;
    }
  }

  // Action methods
  Future<void> _blockSelectedCategories() async {
    if (_selectedCategories.isEmpty) return;
    
    try {
      final success = await _usageService.blockAppsNow(
        appPackageNames: [],
        categories: _selectedCategories,
        durationMinutes: _blockDurationMinutes,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blocked ${_selectedCategories.length} categories for ${_fmtMinutes(_blockDurationMinutes)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedCategories.clear();
        });
        
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to block apps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _unblockApp(Apps app) async {
    try {
      final success = await _usageService.unblockApps(
        appPackageNames: [app.packageName!],
        categories: [],
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unblocked ${app.appName ?? app.packageName}'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _blockCategory(String category) async {
    try {
      final success = await _usageService.blockAppsNow(
        appPackageNames: [],
        categories: [category],
        durationMinutes: 60,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blocked all $category apps for 1 hour'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleSchedule(AppBlockSchedule schedule, bool value) {
    final updatedSchedule = schedule.copyWith(isActive: value);
    _usageService.updateBlockSchedule(updatedSchedule);
    setState(() {});
  }

  void _editSchedule(AppBlockSchedule schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule editing coming soon!')),
    );
  }

  void _showAddScheduleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule creation coming soon!')),
    );
  }

  void _createFocusTimeSchedule() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
    final endTime = DateTime(now.year, now.month, now.day, 17, 0); // 5:00 PM
    
    final schedule = AppBlockSchedule(
      id: 'focus_time_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Focus Time',
      description: 'Block distracting apps during work hours',
      appPackageNames: [],
      categories: ['Social', 'Entertainment', 'Gaming'],
      startTime: startTime,
      endTime: endTime,
      daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
      isActive: true,
      isRecurring: true,
      focusMode: 'Deep Work',
      createdAt: DateTime.now(),
    );
    
    _usageService.addBlockSchedule(schedule);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Focus Time schedule created!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createSleepModeSchedule() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 22, 0); // 10:00 PM
    final endTime = DateTime(now.year, now.month, now.day + 1, 7, 0); // 7:00 AM next day
    
    final schedule = AppBlockSchedule(
      id: 'sleep_mode_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Sleep Mode',
      description: 'Block all apps during bedtime',
      appPackageNames: [],
      categories: ['Social', 'Entertainment', 'Gaming', 'Productivity'],
      startTime: startTime,
      endTime: endTime,
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      isActive: true,
      isRecurring: true,
      focusMode: 'Sleep',
      createdAt: DateTime.now(),
    );
    
    _usageService.addBlockSchedule(schedule);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep Mode schedule created!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createStudySchedule() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 19, 0); // 7:00 PM
    final endTime = DateTime(now.year, now.month, now.day, 21, 0); // 9:00 PM
    
    final schedule = AppBlockSchedule(
      id: 'study_session_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Study Session',
      description: 'Block entertainment apps for studying',
      appPackageNames: [],
      categories: ['Entertainment', 'Gaming', 'Social'],
      startTime: startTime,
      endTime: endTime,
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      isActive: true,
      isRecurring: true,
      focusMode: 'Study',
      createdAt: DateTime.now(),
    );
    
    _usageService.addBlockSchedule(schedule);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study Session schedule created!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _AppIconFromBase64 extends StatelessWidget {
  final String? base64;
  const _AppIconFromBase64({this.base64});
  
  @override
  Widget build(BuildContext context) {
    if (base64 == null || base64!.isEmpty) {
      return const Icon(Icons.apps);
    }
    try {
      final bytes = const Base64Decoder().convert(base64!);
      return Image.memory(bytes, width: 20, height: 20, fit: BoxFit.contain);
    } catch (_) {
      return const Icon(Icons.apps);
    }
  }
}


