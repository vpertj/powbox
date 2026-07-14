import 'package:flutter/material.dart';
import 'package:pwbox/core/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// "关于"设置选项卡
/// 显示应用程序的版本信息、作者信息和描述
class AboutSettingsTab extends StatefulWidget {
  /// 构造函数
  ///
  /// [key] 组件键
  const AboutSettingsTab({super.key});

  @override
  State<AboutSettingsTab> createState() => _AboutSettingsTabState();
}

/// "关于"设置选项卡状态类
class _AboutSettingsTabState extends State<AboutSettingsTab> {
  /// 应用程序版本
  String _appVersion = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里初始化依赖于 context 的值
    _appVersion = AppLocalizations.of(context)!.loading; // 设置初始版本为"加载中"
    _loadAppVersion(); // 加载应用程序版本
  }

  /// 加载应用程序版本
  Future<void> _loadAppVersion() async {
    // 从平台获取包信息
    final packageInfo = await PackageInfo.fromPlatform();
    // 如果组件仍然挂载
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version; // 设置应用程序版本
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取本地化文本
    final appLocalizations = AppLocalizations.of(context)!;

    // 返回居中组件
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(5.0), // 滚动视图内边距
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0), // 卡片外边距
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距
            child: Column(
              mainAxisSize: MainAxisSize.min, // 最小主轴尺寸
              crossAxisAlignment: CrossAxisAlignment.start, // 交叉轴起始对齐
              children: [
                // 标题
                Text(
                  appLocalizations.aboutPwBox, // "关于 PwBox"
                  style: Theme.of(context).textTheme.headlineSmall, // 标题样式
                ),
                const SizedBox(height: 16.0),
                // 版本信息
                ListTile(
                  leading: const Icon(Icons.info_outline), // 信息图标
                  title: Text(appLocalizations.appVersion), // "应用版本"
                  subtitle: Text(_appVersion), // 应用程序版本
                ),
                // 作者信息
                ListTile(
                  leading: const Icon(Icons.person_outline), // 人物图标
                  title: Text(appLocalizations.author), // "作者"
                  subtitle: Text('vpertj'),
                ),
                // 应用描述
                ListTile(
                  leading: const Icon(Icons.description_outlined), // 描述图标
                  // title: Text(appLocalizations.aboutPwBoxDescription),
                  subtitle: Text(
                    appLocalizations.aboutPwBoxLongDescription,
                  ), // 应用程序描述
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
