# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# 保持应用特定类
-keep class cn.younglee.pomodoro.** { *; }

# SQLite相关
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Kotlin相关
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-keep class kotlin.Metadata { *; }

# 保持所有JSON相关类的完整性
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 保持Serializable类不被混淆
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保持Parcelable类不被混淆
-keepnames class * implements android.os.Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
} 