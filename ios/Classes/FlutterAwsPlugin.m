#import "FlutterAwsPlugin.h"
#import <flutter_aws_plugin/flutter_aws_plugin-Swift.h>

@implementation FlutterAwsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAwsPlugin registerWithRegistrar:registrar];
}
@end
