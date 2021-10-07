//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<android_notification_listener2/AndroidNotificationListener2Plugin.h>)
#import <android_notification_listener2/AndroidNotificationListener2Plugin.h>
#else
@import android_notification_listener2;
#endif

#if __has_include(<sqflite/SqflitePlugin.h>)
#import <sqflite/SqflitePlugin.h>
#else
@import sqflite;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AndroidNotificationListener2Plugin registerWithRegistrar:[registry registrarForPlugin:@"AndroidNotificationListener2Plugin"]];
  [SqflitePlugin registerWithRegistrar:[registry registrarForPlugin:@"SqflitePlugin"]];
}

@end
