class Apps {
  final String appName;
  final String apkFilePath;
  final String packageName;
  final String versionName;
  final String versionCode;
  final String dataDir;
  final int systemApp;
  final int installTimeMillis;
  final String category;
  final int enabled;

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
    };
  }
}
