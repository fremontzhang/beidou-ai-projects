# Beidou AI 模型展示网页 - 火山云部署方案

## 📋 项目概述

将Beidou AI模型展示网页部署到火山云（Volcano Engine）平台，提供稳定、高效的在线访问服务。

## 🏗️ 云资源架构设计

### 推荐配置方案

#### 方案一：基础版（适合演示/测试）
```
云服务器ECS：2核4G，40GB SSD盘，5Mbps带宽
域名：.com/.cn 域名1个
SSL证书：免费版SSL证书
安全组：HTTP/HTTPS/SSH端口开放
```
**预估月成本：¥100-200**

#### 方案二：生产版（适合正式运营）
```
云服务器ECS：4核8G，100GB SSD盘，10Mbps带宽
负载均衡：CLB实例1个（可选）
CDN：全站加速CDN
域名：.com/.cn 域名1个
SSL证书：企业版SSL证书
云监控：基础监控+告警
```
**预估月成本：¥300-500**

## 🚀 详细部署步骤

### 第一阶段：账号准备和资源购买

#### 1.1 火山云账号注册和认证
- 访问 [火山云官网](https://www.volcengine.com/)
- 注册账号并完成实名认证
- 充值相应金额（建议至少充值200元）

#### 1.2 购买云服务器ECS
1. 登录火山云控制台
2. 选择"产品 > 计算 > 云服务器ECS"
3. 点击"创建实例"：
   ```
   实例规格：2核4G（基础版）/ 4核8G（生产版）
   镜像：Ubuntu 20.04 LTS
   系统盘：40GB SSD
   网络：默认VPC和子网
   公网IP：分配公网IP
   带宽：5Mbps（基础版）/ 10Mbps（生产版）
   安全组：新建安全组
   ```
4. 设置登录密码（复杂密码，保存好）
5. 确认订单并支付

#### 1.3 配置安全组规则
在安全组中添加规则：
```
入站规则：
- SSH：TCP 22 -> 0.0.0.0/0
- HTTP：TCP 80 -> 0.0.0.0/0
- HTTPS：TCP 443 -> 0.0.0.0/0

出站规则：
- 允许所有出站流量
```

#### 1.4 购买域名（可选）
1. 在火山云"域名服务"中购买域名
2. 完成域名实名认证

### 第二阶段：服务器环境配置

#### 2.1 连接服务器
```bash
# 使用SSH连接到服务器
ssh root@YOUR_SERVER_IP
```

#### 2.2 系统基础配置
```bash
# 更新系统
apt update && apt upgrade -y

# 设置时区
timedatectl set-timezone Asia/Shanghai

# 创建非root用户
adduser beidou
usermod -aG sudo beidou

# 配置防火墙
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable
```

#### 2.3 安装必要软件
```bash
# 安装Nginx
apt install nginx -y

# 安装Node.js（如果需要动态功能）
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# 安装SSL证书工具
apt install certbot python3-certbot-nginx -y

# 安装Git
apt install git -y
```

### 第三阶段：Web服务器配置

#### 3.1 配置Nginx
创建Nginx配置文件：
```bash
# 删除默认配置
rm /etc/nginx/sites-enabled/default

# 创建网站配置
nano /etc/nginx/sites-available/beidou-ai
```

配置内容：
```nginx
server {
    listen 80;
    server_name YOUR_DOMAIN.com www.YOUR_DOMAIN.com;

    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name YOUR_DOMAIN.com www.YOUR_DOMAIN.com;

    # SSL证书配置（稍后配置）
    # ssl_certificate /etc/letsencrypt/live/YOUR_DOMAIN.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/YOUR_DOMAIN.com/privkey.pem;

    # 网站根目录
    root /var/www/beidou-ai;
    index index.html;

    # 性能优化
    location ~* \.(html|css|js|jpg|jpeg|png|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # 压缩
    gzip on;
    gzip_types text/css application/javascript application/json text/javascript text/plain application/xml;
    gzip_min_length 1000;

    # 防止直接访问敏感文件
    location ~ /\. {
        deny all;
    }
}
```

启用配置：
```bash
# 启用配置
ln -s /etc/nginx/sites-available/beidou-ai /etc/nginx/sites-enabled/

# 测试配置
nginx -t

# 重启Nginx
systemctl restart nginx
```

### 第四阶段：网站部署

#### 4.1 创建网站目录
```bash
# 创建网站根目录
mkdir -p /var/www/beidou-ai
chown -R beidou:beidou /var/www/beidou-ai
```

#### 4.2 上传网站文件
方法一：使用SCP上传
```bash
# 在本地执行
scp openrouter-models-explorer.html beidou@YOUR_SERVER_IP:/var/www/beidou-ai/index.html
```

方法二：使用Git（推荐）
```bash
# 切换到beidou用户
su - beidou

# 克隆代码库（如果有）
cd /var/www/beidou-ai
git clone YOUR_REPO_URL .

# 或者直接创建文件
# 将HTML文件内容复制到/var/www/beidou-ai/index.html
```

### 第五阶段：SSL证书配置

#### 5.1 申请免费SSL证书
```bash
# 使用Certbot申请证书
sudo certbot --nginx -d YOUR_DOMAIN.com -d www.YOUR_DOMAIN.com

# 按照提示操作，选择HTTP重定向到HTTPS
```

#### 5.2 设置证书自动续期
```bash
# 添加自动续期任务
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### 第六阶段：域名解析配置

#### 6.1 配置DNS解析
在火山云域名服务中添加A记录：
```
主机记录：@     记录值：YOUR_SERVER_IP   TTL：300
主机记录：www   记录值：YOUR_SERVER_IP   TTL：300
```

### 第七阶段：监控和维护

#### 7.1 安装监控工具
```bash
# 安装基础监控
apt install htop iotop nethogs -y

# 配置火山云监控Agent（根据火山云文档）
```

#### 7.2 设置日志轮转
```bash
# 创建日志轮转配置
nano /etc/logrotate.d/beidou-ai
```

内容：
```
/var/log/nginx/beidou-ai.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    postrotate
        systemctl reload nginx
    endscript
}
```

## 📋 部署脚本

### 自动化部署脚本
```bash
#!/bin/bash
# deploy.sh - Beidou AI网站部署脚本

set -e

# 配置变量
DOMAIN="YOUR_DOMAIN.com"
SERVER_IP="YOUR_SERVER_IP"
WEB_ROOT="/var/www/beidou-ai"

echo "🚀 开始部署Beidou AI网站..."

# 更新系统
echo "📦 更新系统..."
apt update && apt upgrade -y

# 安装依赖
echo "🔧 安装必要软件..."
apt install nginx certbot python3-certbot-nginx git htop -y

# 创建用户
if ! id "beidou" &>/dev/null; then
    echo "👤 创建beidou用户..."
    adduser beidou --disabled-password --gecos ""
    usermod -aG sudo beidou
fi

# 创建网站目录
echo "📁 创建网站目录..."
mkdir -p $WEB_ROOT
chown -R beidou:beidou $WEB_ROOT

# 配置Nginx
echo "🌐 配置Nginx..."
cat > /etc/nginx/sites-available/beidou-ai << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # 性能优化
    location ~* \.(html|css|js|jpg|jpeg|png|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
}
EOF

# 启用Nginx配置
ln -sf /etc/nginx/sites-available/beidou-ai /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试Nginx配置
nginx -t
systemctl restart nginx

# 配置防火墙
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

echo "✅ 部署完成！"
echo "📝 下一步操作："
echo "1. 将HTML文件上传到 $WEB_ROOT/index.html"
echo "2. 配置域名解析到 $SERVER_IP"
echo "3. 运行: certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo "4. 访问: https://$DOMAIN"
```

## 💰 成本预估

### 基础版配置
- **云服务器ECS**：2核4G，40GB SSD，5Mbps → ¥80-120/月
- **域名**：.com/.cn → ¥60-100/年
- **SSL证书**：免费 → ¥0
- **带宽流量**：基础套餐 → ¥20-50/月
- **总计**：约 ¥100-200/月

### 生产版配置
- **云服务器ECS**：4核8G，100GB SSD，10Mbps → ¥200-300/月
- **CDN加速**：按流量计费 → ¥50-100/月
- **负载均衡CLB**：实例费用 → ¥30-50/月
- **域名**：.com/.cn → ¥60-100/年
- **SSL证书**：免费/企业版 → ¥0-500/年
- **总计**：约 ¥300-500/月

## 🛠️ 运维建议

### 日常维护
1. **定期备份**：
   ```bash
   # 每周备份网站文件
   tar -czf /backup/beidou-ai-$(date +%Y%m%d).tar.gz /var/www/beidou-ai
   ```

2. **系统更新**：
   ```bash
   # 每月更新系统
   apt update && apt upgrade -y
   ```

3. **日志监控**：
   ```bash
   # 监控Nginx日志
   tail -f /var/log/nginx/access.log
   tail -f /var/log/nginx/error.log
   ```

4. **性能监控**：
   ```bash
   # 监控系统资源
   htop
   iotop
   nethogs
   ```

### 安全加固
1. **SSH安全配置**：
   ```bash
   # 修改SSH配置
   nano /etc/ssh/sshd_config

   # 添加配置
   PermitRootLogin no
   PasswordAuthentication no
   UsePAM no
   ```

2. **防火墙配置**：
   ```bash
   # 限制SSH访问IP
   ufw allow from YOUR_IP to any port 22
   ```

3. **定期安全扫描**：
   ```bash
   # 安装安全扫描工具
   apt install lynis -y
   lynis audit system
   ```

### 扩容方案
当访问量增长时，可以考虑：
1. **升级ECS配置**：直接升级CPU、内存、带宽
2. **使用负载均衡**：添加CLB分发流量
3. **启用CDN加速**：减轻服务器压力
4. **数据库优化**：如需要动态功能，可使用RDS数据库

## 📞 技术支持

- **火山云文档**：https://www.volcengine.com/docs
- **Nginx文档**：https://nginx.org/en/docs/
- **Certbot文档**：https://certbot.eff.org/docs/

## ⚠️ 注意事项

1. **安全性**：定期更新系统和软件，使用强密码
2. **备份**：定期备份网站文件和配置
3. **监控**：设置监控告警，及时发现问题
4. **成本控制**：注意带宽使用，避免超出预算
5. **法律合规**：确保网站内容符合相关法律法规

---

**部署完成后，你的Beidou AI模型展示网站将通过https://YOUR_DOMAIN.com访问！**