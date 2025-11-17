# 🚀 Beidou AI Projects

Claude Code生成的项目集合，包含AI模型展示、部署方案、工具脚本等。

## 📁 项目结构

```
beidou-ai-projects/
├── README.md                    # 项目总览
├── Labs/                        # 实验项目集合
│   ├── README.md               # Labs项目详情
│   ├── web-projects/           # Web应用项目
│   │   └── openrouter-models-explorer.html
│   ├── deployment/             # 部署方案和脚本
│   │   ├── volcengine-deployment-plan.md
│   │   ├── deploy-beidou-ai.sh
│   │   └── maintenance-scripts.sh
│   ├── docs/                   # 文档资料
│   │   ├── quick-start-guide.md
│   │   └── project-summary.md
│   └── scripts/                # 工具脚本
│       └── github-sync.sh
├── scripts/                    # 全局工具脚本
└── docs/                       # 全局文档
```

## 🔬 Labs项目

### 核心项目：OpenRouter AI模型展示
- **文件**：`Labs/web-projects/openrouter-models-explorer.html`
- **功能**：动态展示OpenRouter所有AI模型的详细信息
- **特性**：
  - 🔄 实时获取OpenRouter API数据
  - 🏷️ 智能分类（编程、推理、多模态等）
  - 💰 完整价格信息和技术规格
  - 📱 响应式设计，支持移动端
  - 🔍 实时搜索和筛选功能

### 完整部署方案
- **文档**：`Labs/deployment/volcengine-deployment-plan.md`
- **脚本**：`Labs/deployment/deploy-beidou-ai.sh`
- **平台**：火山云（Volcano Engine）
- **特性**：一键部署、SSL配置、运维监控

## 🚀 快速开始

### 1. 查看项目
```bash
# 克隆仓库
git clone https://github.com/fremontzhang/beidou-ai-projects.git
cd beidou-ai-projects

# 查看项目结构
ls -la Labs/
```

### 2. 本地测试
```bash
# 在浏览器中打开AI模型展示页面
open Labs/web-projects/openrouter-models-explorer.html
```

### 3. 部署到服务器
```bash
# 复制部署脚本到服务器
scp Labs/deployment/deploy-beidou-ai.sh root@你的服务器:/root/

# 在服务器上执行部署
ssh root@你的服务器
bash deploy-beidou-ai.sh
```

## 🛠️ 开发工具

### GitHub同步工具
```bash
# 同步项目到GitHub
bash Labs/scripts/github-sync.sh "项目描述" 文件路径
```

### 运维管理
```bash
# 服务器运维工具
bash Labs/deployment/maintenance-scripts.sh
```

## 📊 项目状态

| 项目类型 | 状态 | 描述 |
|---------|------|------|
| AI模型展示 | ✅ 完成 | OpenRouter模型展示平台 |
| 部署方案 | ✅ 完成 | 火山云一键部署方案 |
| 同步工具 | ✅ 完成 | GitHub自动同步工具 |
| 运维脚本 | ✅ 完成 | 服务器监控和维护工具 |

## 🔮 项目路线图

### 正在开发
- [ ] AI模型对比工具
- [ ] API在线测试器
- [ ] 部署自动化CI/CD
- [ ] 监控仪表板

### 计划功能
- [ ] 多AI服务商支持
- [ ] 性能基准测试
- [ ] 团队协作功能
- [ ] 国际化支持

## 📞 技术支持

### 文档资源
- **Labs项目详情**：`Labs/README.md`
- **部署指南**：`Labs/docs/quick-start-guide.md`
- **项目总结**：`Labs/docs/project-summary.md`

### 外部链接
- **OpenRouter API**：https://openrouter.ai/docs
- **GitHub仓库**：https://github.com/fremontzhang/beidou-ai-projects

## 📄 许可证

本项目采用 MIT 许可证。

---

**🤖 由Claude Code生成和维护 | 持续更新中**