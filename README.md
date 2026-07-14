# PwBox - 安全密码管理器

PwBox 是一个安全、开源的跨平台密码管理器，帮助您安全地存储和管理所有密码。

## 功能特性

- 🔒 **军事级加密** - 使用 Argon2 和 AES-256-GCM 加密保护您的数据
- 🌐 **跨平台支持** - 支持 Windows、macOS、Linux
- 📱 **直观界面** - 现代化的用户界面，易于使用
- 🏠 **分组管理** - 按类别组织您的密码条目
- 🔍 **强大搜索** - 快速查找您的密码条目
- 🗃️ **附件支持** - 为密码条目添加文件附件
- 🔄 **自动备份** - 自动备份您的数据库以防数据丢失
- 🗑️ **回收站** - 误删的条目可以恢复
- 🔐 **双因素认证** - 额外的安全层保护
- 🌓 **深色/浅色主题** - 根据您的喜好选择界面主题
- 🌍 **多语言支持** - 支持中文和英文界面

## 开始使用

### 系统要求

- Windows 10 或更高版本
- macOS 10.15 或更高版本
- Linux (Ubuntu 20.04 或类似发行版)

### 安装

1. 从 [发布页面](https://github.com/your-username/pwbox/releases) 下载适合您系统的安装包
2. 运行安装程序并按照提示完成安装
3. 启动 PwBox 并创建您的第一个密码数据库

### 开发

如果您想从源代码构建 PwBox：

#### 前提条件

- Flutter SDK 3.0 或更高版本
- Dart SDK 2.17 或更高版本

#### 构建步骤

```bash
# 克隆仓库
git clone https://github.com/your-username/pwbox.git
cd pwbox

# 获取依赖
flutter pub get

# 运行应用
flutter run

# 构建发布版本
flutter build windows  # Windows
flutter build macos    # macOS
flutter build linux    # Linux
```

## 使用说明

1. **创建数据库** - 首次启动时，选择创建新数据库并设置主密码
2. **添加条目** - 点击 "+" 按钮添加新的密码条目
3. **组织分组** - 创建分组来分类管理您的密码
4. **搜索条目** - 使用顶部搜索框快速查找密码
5. **生成密码** - 使用内置密码生成器创建强密码
6. **启用备份** - 在设置中启用自动备份保护您的数据

## 安全性

- 所有数据在本地使用 Argon2 和 AES-256-GCM 加密
- 主密码永远不会存储在设备上
- 数据库文件经过加密，即使物理访问也无法读取
- 双因素认证提供额外的安全保护层

## 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

项目链接: [https://github.com/your-username/pwbox](https://github.com/your-username/pwbox)

## 致谢

- [Flutter](https://flutter.dev/)
- [Argon2](https://github.com/P-H-C/phc-winner-argon2)
- [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)