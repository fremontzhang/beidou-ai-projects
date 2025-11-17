# Beidou AI网站快速部署指南

## 🚀 一键部署命令

### 1. 上传部署脚本到服务器
```bash
# 上传部署脚本
scp deploy-beidou-ai.sh root@你的服务器IP:/root/

# 上传网站文件
scp openrouter-models-explorer.html root@你的服务器IP:/tmp/
```

### 2. 连接服务器并执行部署
```bash
# SSH连接到服务器
ssh root@你的服务器IP

# 给脚本执行权限
chmod +x deploy-beidou-ai.sh

# 执行部署脚本
sudo bash deploy-beidou-ai.sh
```

### 3. 按提示输入信息
脚本会要求输入：
- 域名（如：beidou-ai.com）
- 服务器IP地址

### 4. 部署后操作
```bash
# 上传网站文件
mv /tmp/openrouter-models-explorer.html /var/www/beidou-ai/index.html
chown beidou:beidou /var/www/beidou-ai/index.html

# 配置SSL证书
certbot --nginx -d 你的域名 -d www.你的域名
```

## 📋 火山云购买指南

### 1. 注册账号
- 访问：https://www.volcengine.com/
- 完成实名认证

### 2. 购买ECS服务器
```
实例规格：2核4G
镜像：Ubuntu 20.04 LTS
系统盘：40GB SSD
网络：默认VPC
公网IP：分配
带宽：5Mbps
安全组：新建
```

### 3. 配置安全组
添加入站规则：
- SSH: 22
- HTTP: 80
- HTTPS: 443

## 🔧 常用命令

### 网站管理
```bash
# 重启Nginx
systemctl restart nginx

# 查看Nginx状态
systemctl status nginx

# 查看Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# 测试Nginx配置
nginx -t
```

### 文件管理
```bash
# 编辑网站文件
nano /var/www/beidou-ai/index.html

# 上传新文件
scp 新文件.html beidou@服务器IP:/var/www/beidou-ai/

# 备份网站
tar -czf beidou-ai-backup-$(date +%Y%m%d).tar.gz /var/www/beidou-ai
```

### SSL证书管理
```bash
# 续期证书
certbot renew

# 查看证书状态
certbot certificates

# 手动续期
certbot --nginx -d 域名 -d www.域名
```

### 系统监控
```bash
# 查看系统资源
htop

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看网络连接
netstat -tulpn
```

## 🛠️ 故障排除

### 网站无法访问
1. 检查Nginx状态：`systemctl status nginx`
2. 检查防火墙：`ufw status`
3. 检查端口：`netstat -tulpn | grep :80`
4. 查看错误日志：`tail -f /var/log/nginx/error.log`

### SSL证书问题
1. 检查证书有效性：`certbot certificates`
2. 重新申请证书：`certbot --nginx -d 域名 -d www.域名`
3. 检查证书路径：`ls /etc/letsencrypt/live/域名/`

### 文件权限问题
```bash
# 修复网站目录权限
chown -R beidou:beidou /var/www/beidou-ai
chmod -R 755 /var/www/beidou-ai
```

## 📞 技术支持

如遇问题，可通过以下方式解决：
1. 查看详细部署文档：volcengine-deployment-plan.md
2. 火山云官方文档：https://www.volcengine.com/docs
3. Nginx官方文档：https://nginx.org/en/docs/

---

**快速部署完成后，你的Beidou AI模型展示网站将正式上线！**