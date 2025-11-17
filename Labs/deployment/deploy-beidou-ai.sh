#!/bin/bash
# Beidou AI网站一键部署脚本
# 作者：Claude Code
# 版本：v1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
DOMAIN=""
SERVER_IP=""
WEB_ROOT="/var/www/beidou-ai"
CURRENT_USER=$(whoami)

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "此脚本需要root权限运行，请使用: sudo bash deploy-beidou-ai.sh"
        exit 1
    fi
}

# 获取用户输入
get_user_input() {
    print_step "请输入配置信息:"

    read -p "域名 (例如: beidou-ai.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_error "域名不能为空"
        exit 1
    fi

    read -p "服务器IP地址: " SERVER_IP
    if [[ -z "$SERVER_IP" ]]; then
        print_error "服务器IP地址不能为空"
        exit 1
    fi

    # 确认配置
    echo
    print_message "配置确认:"
    echo "域名: $DOMAIN"
    echo "服务器IP: $SERVER_IP"
    echo
    read -p "确认配置正确吗? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_error "用户取消部署"
        exit 1
    fi
}

# 系统检查和更新
system_setup() {
    print_step "更新系统软件包..."
    apt update && apt upgrade -y

    print_step "安装基础工具..."
    apt install -y curl wget git htop iotop nethogs unzip
}

# 安装Nginx
install_nginx() {
    print_step "安装Nginx..."
    apt install -y nginx

    # 启动并设置开机自启
    systemctl start nginx
    systemctl enable nginx

    print_message "Nginx安装完成"
}

# 安装SSL证书工具
install_certbot() {
    print_step "安装Certbot SSL证书工具..."
    apt install -y certbot python3-certbot-nginx
    print_message "Certbot安装完成"
}

# 创建网站用户
create_website_user() {
    if ! id "beidou" &>/dev/null; then
        print_step "创建网站用户beidou..."
        adduser --disabled-password --gecos "" beidou
        usermod -aG sudo beidou
        print_message "用户beidou创建完成"
    else
        print_warning "用户beidou已存在，跳过创建"
    fi
}

# 创建网站目录
create_web_directory() {
    print_step "创建网站目录..."
    mkdir -p $WEB_ROOT
    chown -R beidou:beidou $WEB_ROOT
    chmod 755 $WEB_ROOT
    print_message "网站目录创建完成: $WEB_ROOT"
}

# 配置Nginx
configure_nginx() {
    print_step "配置Nginx..."

    # 删除默认配置
    rm -f /etc/nginx/sites-enabled/default

    # 创建网站配置
    cat > /etc/nginx/sites-available/beidou-ai << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # 重定向到HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # SSL证书配置（将在Certbot配置后自动添加）

    # 网站根目录
    root $WEB_ROOT;
    index index.html;

    # 安全配置
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # 压缩配置
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # 静态文件缓存
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }

    # 主页面配置
    location / {
        try_files \$uri \$uri/ =404;
    }

    # 安全配置 - 禁止访问敏感文件
    location ~ /\. {
        deny all;
    }

    location ~ ~$ {
        deny all;
    }
}
EOF

    # 启用配置
    ln -sf /etc/nginx/sites-available/beidou-ai /etc/nginx/sites-enabled/

    # 测试配置
    if nginx -t; then
        print_message "Nginx配置测试通过"
        systemctl reload nginx
    else
        print_error "Nginx配置有误"
        exit 1
    fi
}

# 配置防火墙
configure_firewall() {
    print_step "配置防火墙..."

    # 启用UFW
    ufw --force enable

    # 允许SSH（先允许SSH，防止被锁）
    ufw allow 22/tcp

    # 允许HTTP和HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp

    print_message "防火墙配置完成"
}

# 上传示例页面
upload_sample_page() {
    print_step "上传示例页面..."

    cat > $WEB_ROOT/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Beidou AI - 部署成功</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            max-width: 600px;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
        }
        .success {
            color: #28a745;
            font-size: 4rem;
            margin-bottom: 20px;
        }
        .info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .step {
            text-align: left;
            margin: 10px 0;
            padding: 10px;
            background: #e9ecef;
            border-radius: 5px;
        }
        .step-title {
            font-weight: bold;
            color: #495057;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success">✅</div>
        <h1>Beidou AI 网站部署成功！</h1>
        <p>服务器环境已配置完成，接下来请完成以下步骤：</p>

        <div class="info">
            <div class="step">
                <div class="step-title">1. 上传网站文件</div>
                <p>将你的 openrouter-models-explorer.html 文件上传到服务器：</p>
                <code>scp openrouter-models-explorer.html beidou@${SERVER_IP}:/var/www/beidou-ai/index.html</code>
            </div>

            <div class="step">
                <div class="step-title">2. 配置域名解析</div>
                <p>在你的域名服务商处添加A记录：</p>
                <code>@ -> ${SERVER_IP}</code><br>
                <code>www -> ${SERVER_IP}</code>
            </div>

            <div class="step">
                <div class="step-title">3. 申请SSL证书</div>
                <p>在服务器上运行以下命令：</p>
                <code>certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}</code>
            </div>

            <div class="step">
                <div class="step-title">4. 访问网站</div>
                <p>完成以上步骤后，访问：https://${DOMAIN}</p>
            </div>
        </div>

        <p style="color: #666; margin-top: 30px;">
            如需帮助，请查看部署文档或联系技术支持。
        </p>
    </div>
</body>
</html>
EOF

    chown beidou:beidou $WEB_ROOT/index.html
    print_message "示例页面创建完成"
}

# 创建日志轮转配置
create_logrotate_config() {
    print_step "创建日志轮转配置..."

    cat > /etc/logrotate.d/beidou-ai << EOF
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
EOF

    print_message "日志轮转配置创建完成"
}

# 显示部署结果
show_deployment_result() {
    print_message "🎉 Beidou AI网站基础环境部署完成！"
    echo
    print_message "部署信息:"
    echo "域名: $DOMAIN"
    echo "服务器IP: $SERVER_IP"
    echo "网站目录: $WEB_ROOT"
    echo
    print_message "下一步操作:"
    echo "1. 配置域名解析: $DOMAIN -> $SERVER_IP"
    echo "2. 上传你的HTML文件到 $WEB_ROOT/"
    echo "3. 申请SSL证书: certbot --nginx -d $DOMAIN -d www.$DOMAIN"
    echo "4. 访问网站: http://$DOMAIN (证书配置后使用HTTPS)"
    echo
    print_warning "重要提醒:"
    echo "- 请及时修改SSH默认配置，提高安全性"
    echo "- 定期备份网站文件和配置"
    echo "- 监控服务器资源使用情况"
}

# 主函数
main() {
    print_message "开始部署Beidou AI网站..."
    echo

    check_root
    get_user_input
    echo

    system_setup
    install_nginx
    install_certbot
    create_website_user
    create_web_directory
    configure_nginx
    configure_firewall
    upload_sample_page
    create_logrotate_config
    echo

    show_deployment_result
}

# 执行主函数
main "$@"