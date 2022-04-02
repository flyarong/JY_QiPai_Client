-ignorewarnings 
-keepattributes *Annotation* 
-keepattributes Exceptions 
-keepattributes InnerClasses 
-keepattributes Signature 
-keepattributes SourceFile,LineNumberTable 
-keep class com.hianalytics.android.**{*;} 
-keep class com.huawei.updatesdk.**{*;} 
-keep class com.huawei.hms.**{*;} 
-keep class com.huawei.gamebox.plugin.gameservice.**{*;}
-keep interface com.huawei.hms.analytics.type.HAEventType{*;}
-keep interface com.huawei.hms.analytics.type.HAParamType{*;}
-keep class com.huawei.hms.analytics.HiAnalyticsTools{
        public static void enableLog();
        public static void enableLog(int);
}
-keep class com.huawei.hms.analytics.HiAnalyticsInstance{*;}
-keep class com.huawei.hms.analytics.HiAnalytics{*;}