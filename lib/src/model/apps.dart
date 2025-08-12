class Apps {
  final String? appName;
  final String? apkFilePath;
  final String? packageName;
  final String? versionName;
  final String? versionCode;
  final String? dataDir;
  final int? systemApp;
  final int? installTimeMillis;
  final String? category;
  final int? enabled;
  
  // Enhanced fields for usage tracking and blocking
  String? appType; // 'Productive', 'Distracting', 'Neutral', 'Social', 'Entertainment', 'Work', 'Education'
  int? dailyUsageMinutes;
  int? weeklyUsageMinutes;
  int? monthlyUsageMinutes;
  bool? isBlocked;
  DateTime? lastBlockedTime;
  List<String>? blockSchedules; // List of schedule IDs
  double? focusScore; // 0.0 to 1.0 based on usage patterns
  String? iconBase64;
  DateTime? lastUsedTime;
  int? totalLaunches;
  bool? isSystemApp;

  static const String TABLENAME = "deviceapps";

  Apps({
    this.appName,
    this.apkFilePath,
    this.packageName,
    this.versionName,
    this.versionCode,
    this.dataDir,
    this.systemApp,
    this.installTimeMillis,
    this.category,
    this.enabled,
    this.appType,
    this.dailyUsageMinutes,
    this.weeklyUsageMinutes,
    this.monthlyUsageMinutes,
    this.isBlocked,
    this.lastBlockedTime,
    this.blockSchedules,
    this.focusScore,
    this.iconBase64,
    this.lastUsedTime,
    this.totalLaunches,
    this.isSystemApp,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'apkFilePath': apkFilePath,
      'packageName': packageName,
      'versionName': versionName,
      'versionCode': versionCode,
      'dataDir': dataDir,
      'systemApp': systemApp,
      'installTimeMillis': installTimeMillis,
      'category': category,
      'enabled': enabled,
      'appType': appType,
      'dailyUsageMinutes': dailyUsageMinutes,
      'weeklyUsageMinutes': weeklyUsageMinutes,
      'monthlyUsageMinutes': monthlyUsageMinutes,
      'isBlocked': isBlocked == true ? 1 : 0,
      'lastBlockedTime': lastBlockedTime?.millisecondsSinceEpoch,
      'blockSchedules': blockSchedules?.join(','),
      'focusScore': focusScore,
      'iconBase64': iconBase64,
      'lastUsedTime': lastUsedTime?.millisecondsSinceEpoch,
      'totalLaunches': totalLaunches,
      'isSystemApp': isSystemApp == true ? 1 : 0,
    };
  }

  factory Apps.fromMap(Map<String, dynamic> map) {
    return Apps(
      appName: map['appName'],
      apkFilePath: map['apkFilePath'],
      packageName: map['packageName'],
      versionName: map['versionName'],
      versionCode: map['versionCode'],
      dataDir: map['dataDir'],
      systemApp: map['systemApp'],
      installTimeMillis: map['installTimeMillis'],
      category: map['category'],
      enabled: map['enabled'],
      appType: map['appType'],
      dailyUsageMinutes: map['dailyUsageMinutes'],
      weeklyUsageMinutes: map['weeklyUsageMinutes'],
      monthlyUsageMinutes: map['monthlyUsageMinutes'],
      isBlocked: map['isBlocked'] == 1,
      lastBlockedTime: map['lastBlockedTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastBlockedTime']) 
          : null,
      blockSchedules: map['blockSchedules'] != null 
          ? map['blockSchedules'].split(',') 
          : null,
      focusScore: map['focusScore']?.toDouble(),
      iconBase64: map['iconBase64'],
      lastUsedTime: map['lastUsedTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUsedTime']) 
          : null,
      totalLaunches: map['totalLaunches'],
      isSystemApp: map['isSystemApp'] == 1,
    );
  }

  Apps copyWith({
    String? appName,
    String? apkFilePath,
    String? packageName,
    String? versionName,
    String? versionCode,
    String? dataDir,
    int? systemApp,
    int? installTimeMillis,
    String? category,
    int? enabled,
    String? appType,
    int? dailyUsageMinutes,
    int? weeklyUsageMinutes,
    int? monthlyUsageMinutes,
    bool? isBlocked,
    DateTime? lastBlockedTime,
    List<String>? blockSchedules,
    double? focusScore,
    String? iconBase64,
    DateTime? lastUsedTime,
    int? totalLaunches,
    bool? isSystemApp,
  }) {
    return Apps(
      appName: appName ?? this.appName,
      apkFilePath: apkFilePath ?? this.apkFilePath,
      packageName: packageName ?? this.packageName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      dataDir: dataDir ?? this.dataDir,
      systemApp: systemApp ?? this.systemApp,
      installTimeMillis: installTimeMillis ?? this.installTimeMillis,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      appType: appType ?? this.appType,
      dailyUsageMinutes: dailyUsageMinutes ?? this.dailyUsageMinutes,
      weeklyUsageMinutes: weeklyUsageMinutes ?? this.weeklyUsageMinutes,
      monthlyUsageMinutes: monthlyUsageMinutes ?? this.monthlyUsageMinutes,
      isBlocked: isBlocked ?? this.isBlocked,
      lastBlockedTime: lastBlockedTime ?? this.lastBlockedTime,
      blockSchedules: blockSchedules ?? this.blockSchedules,
      focusScore: focusScore ?? this.focusScore,
      iconBase64: iconBase64 ?? this.iconBase64,
      lastUsedTime: lastUsedTime ?? this.lastUsedTime,
      totalLaunches: totalLaunches ?? this.totalLaunches,
      isSystemApp: isSystemApp ?? this.isSystemApp,
    );
  }
}
