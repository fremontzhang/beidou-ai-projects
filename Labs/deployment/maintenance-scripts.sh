#!/bin/bash
# Beidou AI网站运维脚本
# 包含备份、监控、维护等功能

# 配置变量
WEB_ROOT="/var/www/beidou-ai"
BACKUP_DIR="/backup"
LOG_FILE="/var/log/beidou-maintenance.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log "$1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR: $1"
}

# 检查服务状态
check_services() {
    print_status "检查服务状态..."

    # 检查Nginx
    if systemctl is-active --quiet nginx; then
        echo "✅ Nginx: 运行正常"
    else
        echo "❌ Nginx: 未运行"
        systemctl restart nginx
    fi

    # 检查网站文件
    if [ -f "$WEB_ROOT/index.html" ]; then
        echo "✅ 网站文件: 存在"
    else
        echo "❌ 网站文件: 缺失"
    fi

    # 检查SSL证书
    if [ -d "/etc/letsencrypt/live" ]; then
        echo "✅ SSL证书: 已配置"
    else
        echo "❌ SSL证书: 未配置"
    fi
}

# 系统资源监控
monitor_system() {
    print_status "系统资源监控..."

    echo "📊 CPU使用率:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}'

    echo "💾 内存使用情况:"
    free -h

    echo "💿 磁盘使用情况:"
    df -h

    echo "🌐 网络连接数:"
    netstat -an | grep :80 | wc -l
    netstat -an | grep :443 | wc -l
}

# 网站备份
backup_website() {
    print_status "开始备份网站..."

    # 创建备份目录
    mkdir -p $BACKUP_DIR

    # 生成备份文件名
    BACKUP_FILE="$BACKUP_DIR/beidou-ai-backup-$(date +%Y%m%d_%H%M%S).tar.gz"

    # 备份网站文件
    tar -czf "$BACKUP_FILE" -C /var/www beidou-ai

    # 备份Nginx配置
    tar -czf "$BACKUP_DIR/nginx-config-$(date +%Y%m%d_%H%M%S).tar.gz" /etc/nginx/sites-available/beidou-ai

    # 清理30天前的备份
    find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

    echo "✅ 备份完成: $BACKUP_FILE"
    log "备份完成: $BACKUP_FILE"
}

# 日志清理
clean_logs() {
    print_status "清理日志文件..."

    # 清理Nginx日志
    find /var/log/nginx -name "*.log.*" -mtime +7 -delete

    # 清理系统日志
    journalctl --vacuum-time=7d

    # 清理维护日志
    find /var/log -name "*.log" -size +100M -exec truncate -s 50M {} \;

    echo "✅ 日志清理完成"
}

# SSL证书检查
check_ssl_cert() {
    print_status "检查SSL证书状态..."

    if command -v certbot &> /dev/null; then
        echo "🔒 SSL证书状态:"
        certbot certificates

        echo "📅 证书到期时间:"
        find /etc/letsencrypt/live -name "cert.pem" -exec openssl x509 -noout -enddate -in {} \; | sed 's/notAfter=//'

        echo "🔄 尝试续期证书..."
        certbot renew --dry-run
    else
        echo "❌ Certbot未安装"
    fi
}

# 更新系统
update_system() {
    print_status "更新系统软件包..."

    # 更新包列表
    apt update

    # 检查可用更新
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c .)

    if [ "$UPDATES" -gt 0 ]; then
        echo "发现 $UPDATES 个可更新包"
        read -p "是否现在更新? (y/N): " confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            apt upgrade -y
            echo "✅ 系统更新完成"
        else
            echo "⏭️ 跳过系统更新"
        fi
    else
        echo "✅ 系统已是最新"
    fi
}

# 性能优化
optimize_system() {
    print_status "系统性能优化..."

    # 调整内核参数
    echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_max_syn_backlog = 65535' >> /etc/sysctl.conf

    # 应用设置
    sysctl -p

    # 清理系统缓存
    echo 3 > /proc/sys/vm/drop_caches

    echo "✅ 性能优化完成"
}

# 安全检查
security_check() {
    print_status "执行安全检查..."

    # 检查SSH配置
    echo "🔐 SSH安全配置:"
    grep -E "^(PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config || echo "使用默认配置"

    # 检查防火墙状态
    echo "🛡️ 防火墙状态:"
    ufw status verbose

    # 检查登录失败次数
    echo "📝 最近登录失败记录:"
    grep "Failed password" /var/log/auth.log | tail -10

    # 检查可疑IP
    echo "🚫 可疑登录尝试:"
    grep "authentication failure" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -10
}

# 生成状态报告
generate_report() {
    REPORT_FILE="/tmp/beidou-status-report-$(date +%Y%m%d).txt"

    echo "Beidou AI 网站状态报告 - $(date)" > $REPORT_FILE
    echo "=================================" >> $REPORT_FILE

    echo "" >> $REPORT_FILE
    echo "🏥 服务状态:" >> $REPORT_FILE
    systemctl status nginx --no-pager -l >> $REPORT_FILE

    echo "" >> $REPORT_FILE
    echo "📊 系统资源:" >> $REPORT_FILE
    free -h >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    df -h >> $REPORT_FILE

    echo "" >> $REPORT_FILE
    echo "🌐 网站访问统计:" >> $REPORT_FILE
    echo "HTTP访问次数: $(grep -c 'GET /' /var/log/nginx/access.log 2>/dev/null || echo 0)" >> $REPORT_FILE
    echo "HTTPS访问次数: $(grep -c 'GET /' /var/log/nginx/access.log 2>/dev/null || echo 0)" >> $REPORT_FILE

    echo "" >> $REPORT_FILE
    echo "🔒 SSL证书状态:" >> $REPORT_FILE
    if [ -d "/etc/letsencrypt/live" ]; then
        certbot certificates >> $REPORT_FILE 2>&1
    else
        echo "SSL证书未配置" >> $REPORT_FILE
    fi

    echo "✅ 状态报告生成完成: $REPORT_FILE"
}

# 主菜单
show_menu() {
    echo
    echo "🛠️ Beidou AI 运维工具"
    echo "====================="
    echo "1. 检查服务状态"
    echo "2. 系统监控"
    echo "3. 备份网站"
    echo "4. 清理日志"
    echo "5. SSL证书检查"
    echo "6. 更新系统"
    echo "7. 性能优化"
    echo "8. 安全检查"
    echo "9. 生成状态报告"
    echo "10. 执行所有检查"
    echo "0. 退出"
    echo
}

# 主函数
main() {
    while true; do
        show_menu
        read -p "请选择操作 [0-10]: " choice

        case $choice in
            1)
                check_services
                ;;
            2)
                monitor_system
                ;;
            3)
                backup_website
                ;;
            4)
                clean_logs
                ;;
            5)
                check_ssl_cert
                ;;
            6)
                update_system
                ;;
            7)
                optimize_system
                ;;
            8)
                security_check
                ;;
            9)
                generate_report
                ;;
            10)
                echo "🔄 执行全面检查..."
                check_services
                monitor_system
                check_ssl_cert
                security_check
                echo "✅ 全面检查完成"
                ;;
            0)
                echo "👋 再见!"
                exit 0
                ;;
            *)
                echo "❌ 无效选择，请重试"
                ;;
        esac

        echo
        read -p "按回车键继续..."
    done
}

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
    echo "此脚本需要root权限运行，请使用: sudo bash maintenance-scripts.sh"
    exit 1
fi

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行主函数
main