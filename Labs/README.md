# 🔬 Labs - Beidou AI 实验项目

这里存放Beidou AI的实验性项目和原型开发，包括AI模型展示、部署方案、工具脚本等。

## 📁 项目结构

### 🌐 Web项目 (`web-projects/`)
- **OpenRouter AI模型展示** - 动态展示OpenRouter所有AI模型的详细信息
- - `openrouter-models-explorer.html` - 主页面文件
- - 功能特性：实时数据获取、智能分类、响应式设计

### 🚀 部署方案 (`deployment/`)
- **火山云部署方案** - 完整的云部署解决方案
- `volcengine-deployment-plan.md` - 详细部署文档
- `deploy-beidou-ai.sh` - 一键部署脚本
- `maintenance-scripts.sh` - 运维管理脚本

### 📚 文档资料 (`docs/`)
- `quick-start-guide.md` - 快速开始指南
- `project-summary.md` - 项目总结文档
- API文档、使用说明等

### 🛠️ 工具脚本 (`scripts/`)
- `github-sync.sh` - GitHub自动同步工具
- 自动化脚本、工具集等

## 🎯 核心项目展示

### OpenRouter AI模型展示页面

一个功能完整的AI模型展示和查询平台：

#### ✨ 主要特性
- 🔄 **实时数据**：动态获取OpenRouter最新模型信息
- 🏷️ **智能分类**：按使用场景自动分类（编程、推理、多模态等）
- 💰 **详细价格**：完整的计费信息和技术规格
- 📱 **响应式**：完美适配PC和移动端
- 🔍 **搜索筛选**：支持实时搜索和分类过滤

#### 🔧 技术栈
- **前端**：HTML5 + CSS3 + JavaScript
- **API**：OpenRouter REST API
- **部署**：Nginx + 火山云
- **SSL**：Let's Encrypt

#### 🌐 在线访问
部署后可通过域名访问，展示完整的AI模型生态。

## 🚀 快速开始

### 1. 部署OpenRouter模型展示
```bash
# 使用一键部署脚本
bash Labs/deployment/deploy-beidou-ai.sh

# 或参考详细文档
open Labs/deployment/volcengine-deployment-plan.md
```

### 2. 本地测试
```bash
# 直接在浏览器打开
open Labs/web-projects/openrouter-models-explorer.html
```

### 3. GitHub同步
```bash
# 同步新项目到GitHub
bash Labs/scripts/github-sync.sh "项目描述" 文件路径
```

## 📊 项目状态

| 项目 | 状态 | 描述 |
|------|------|------|
| OpenRouter模型展示 | ✅ 完成 | 动态AI模型展示平台 |
| 火山云部署方案 | ✅ 完成 | 完整的云部署解决方案 |
| GitHub同步工具 | ✅ 完成 | 自动化代码同步工具 |
| 运维管理脚本 | ✅ 完成 | 服务器监控和维护工具 |

## 🛠️ 开发工具

### GitHub同步脚本
```bash
# 同步单个文件
./github-sync.sh "添加新功能" 新文件.html

# 同步目录
./github-sync.sh "更新部署方案" deployment/

# 查看同步历史
git log --oneline -10
```

### 运维管理
```bash
# 运行运维工具
bash maintenance-scripts.sh

# 选择对应功能：
# 1. 服务状态检查
# 2. 系统资源监控
# 3. 网站备份
# 4. SSL证书检查
```

## 🔮 未来规划

### 即将开发的项目
- [ ] **AI模型对比工具** - 多模型性能对比平台
- [ ] **API测试工具** - 在线API调用测试器
- [ ] **部署自动化** - CI/CD集成方案
- [ ] **监控仪表板** - 实时监控和告警系统

### 技术优化
- [ ] **性能优化** - CDN集成、缓存策略
- [ ] **移动端优化** - PWA支持
- [ ] **国际化** - 多语言支持
- [ ] **API扩展** - 支持更多AI服务商

## 📞 使用说明

### 环境要求
- **操作系统**：Ubuntu 20.04+ / CentOS 8+
- **Web服务器**：Nginx 1.18+
- **域名**：用于SSL证书配置
- **云平台**：火山云（推荐）或其他云服务商

### 部署步骤
1. **购买云服务器**：推荐2核4G配置
2. **运行部署脚本**：`bash deploy-beidou-ai.sh`
3. **配置域名解析**：指向服务器IP
4. **申请SSL证书**：`certbot --nginx -d 域名`
5. **访问网站**：https://你的域名

### 维护建议
- **定期备份**：使用运维脚本自动备份
- **监控告警**：配置服务器监控
- **证书续期**：Let's Encrypt自动续期
- **安全更新**：定期更新系统和软件

## 🤝 贡献指南

### 提交新项目
1. 在对应目录创建项目文件
2. 更新README说明文档
3. 使用GitHub同步工具提交
4. 创建Pull Request或直接提交到main分支

### 报告问题
- 在Issues中描述问题详情
- 提供错误日志和复现步骤
- 建议解决方案或改进建议

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](../LICENSE) 文件。

---

## 🔗 相关链接

- **OpenRouter API**: https://openrouter.ai/docs
- **火山云文档**: https://www.volcengine.com/docs
- **GitHub仓库**: https://github.com/fremontzhang/beidou-ai-projects

---

**🚀 Labs项目持续更新中，欢迎关注和贡献！**