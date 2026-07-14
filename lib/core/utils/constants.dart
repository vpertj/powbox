/// 数据库路径的键。
const String dbPathKey = 'db_path';

/// 两步验证密钥的键。
const String twoFactorSecretKey = '2fa_secret';

/// 自动备份开关的键。
const String enableAutoBackupKey = 'enable_auto_backup';

/// 自动锁定超时时间的键。
const String autoLockTimeoutKey = 'auto_lock_timeout';

/// 上次备份时间的键。
const String lastBackupTimeKey = 'last_backup_time';

/// 上次备份哈希的键。
const String lastBackupHashKey = 'last_backup_hash';

/// 回收站保留期限的键。
const String recycleBinRetentionKey = 'recycle_bin_retention';

/// 锁定数据库快捷键的键。
const String lockDatabaseShortcutKey = 'lock_database_shortcut';

/// 默认 Argon2 迭代次数（用于密码派生）
/// 这个值决定了密码派生的计算复杂度，较高的值可以提高安全性但会增加解锁时间
const int defaultArgon2Iterations = 10000; // 默认均衡模式

/// 默认 Argon2 内存成本（KB）
/// 这个值决定了密码派生过程中使用的内存量
const int defaultArgon2Memory = 16384; // 16MB

/// 默认 Argon2 并行度
/// 这个值决定了密码派生过程中可以并行执行的线程数
const int defaultArgon2Parallelism = 3; // 增加并行度以利用多核

const double kTitleBarHeight = 32.0;

// 常用间距常量
const double kPaddingSmall = 8.0;
const double kPaddingMedium = 16.0;
const double kPaddingLarge = 24.0;

const double kMarginSmall = 4.0;
const double kMarginMedium = 8.0;
const double kMarginLarge = 16.0;

// Window size and position keys
const String windowWidthKey = 'window_width';
const String windowHeightKey = 'window_height';
const String windowPosXKey = 'window_pos_x';
const String windowPosYKey = 'window_pos_y';

const String splitViewWeightsKey = 'split_view_weights';