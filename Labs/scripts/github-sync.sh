#!/bin/bash
# GitHub自动同步脚本 - Claude代码同步工具
# 使用方法: ./github-sync.sh "提交信息" 文件/目录路径

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
REPO_NAME="beidou-ai-projects"
REPO_DIR="$HOME/github-projects/$REPO_NAME"
DEFAULT_COMMIT_MSG="Claude Code生成 - $(date '+%Y-%m-%d %H:%M:%S')"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$REPO_DIR/.git/sync.log"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
    log "WARNING: $1"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
    log "INFO: $1"
}

# 显示使用说明
show_usage() {
    echo "使用方法:"
    echo "  $0 \"提交信息\" 文件/目录路径"
    echo "  $0 \"提交信息\"                    # 同步当前目录所有文件"
    echo ""
    echo "示例:"
    echo "  $0 \"添加OpenRouter模型展示网页\" openrouter-models-explorer.html"
    echo "  $0 \"添加部署脚本\" deployment/"
    echo "  $0 \"更新文档\" docs/*.md"
    echo ""
}

# 检查参数
if [[ $# -lt 1 ]]; then
    show_usage
    exit 1
fi

COMMIT_MSG="$1"
TARGET_PATH="${2:-.}"

# 检查仓库是否存在
check_repository() {
    if [[ ! -d "$REPO_DIR" ]]; then
        print_error "GitHub仓库不存在: $REPO_DIR"
        print_info "请先运行以下命令创建仓库:"
        print_info "mkdir -p $HOME/github-projects"
        print_info "cd $HOME/github-projects"
        print_info "git clone git@github.com:fremontzhang/$REPO_NAME.git"
        exit 1
    fi
}

# 检查文件是否存在
check_target() {
    if [[ "$TARGET_PATH" != "." ]] && [[ ! -e "$TARGET_PATH" ]]; then
        print_error "目标文件/目录不存在: $TARGET_PATH"
        exit 1
    fi
}

# 切换到仓库目录
cd_to_repo() {
    cd "$REPO_DIR" || {
        print_error "无法切换到仓库目录: $REPO_DIR"
        exit 1
    }
    print_info "已切换到仓库目录: $REPO_DIR"
}

# 同步文件
sync_files() {
    print_info "开始同步文件..."

    # 获取绝对路径
    if [[ "$TARGET_PATH" = "." ]]; then
        # 同步当前目录的所有新文件
        SOURCE_DIR=$(pwd)
        print_info "同步当前目录: $SOURCE_DIR"

        # 复制文件到仓库
        find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.html" -o -name "*.sh" -o -name "*.md" -o -name "*.js" -o -name "*.css" -o -name "*.py" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) -exec cp {} "$REPO_DIR/" \;

        # 复制子目录
        for dir in deployment docs scripts web-projects; do
            if [[ -d "$SOURCE_DIR/$dir" ]]; then
                cp -r "$SOURCE_DIR/$dir" "$REPO_DIR/"
            fi
        done

    else
        SOURCE_PATH=$(realpath "$TARGET_PATH")
        FILENAME=$(basename "$TARGET_PATH")

        if [[ -f "$SOURCE_PATH" ]]; then
            # 同步单个文件
            print_info "同步文件: $FILENAME"
            cp "$SOURCE_PATH" "$REPO_DIR/"
        elif [[ -d "$SOURCE_PATH" ]]; then
            # 同步目录
            print_info "同步目录: $FILENAME"
            cp -r "$SOURCE_PATH" "$REPO_DIR/"
        fi
    fi

    print_success "文件同步完成"
}

# Git操作
git_operations() {
    print_info "执行Git操作..."

    # 检查是否有变更
    if ! git diff --quiet || ! git diff --cached --quiet; then
        # 添加所有文件
        git add .

        # 检查是否有效添加
        if git diff --cached --quiet; then
            print_warning "没有检测到文件变更"
            return 0
        fi

        # 显示将要提交的文件
        print_info "将要提交的文件:"
        git diff --cached --name-only | head -10

        # 提交
        print_info "提交信息: $COMMIT_MSG"
        git commit -m "$COMMIT_MSG"

        # 推送到GitHub
        print_info "推送到GitHub..."
        if git push origin main 2>/dev/null; then
            print_success "代码已成功推送到GitHub!"
        elif git push origin master 2>/dev/null; then
            print_success "代码已成功推送到GitHub!"
        else
            print_error "推送失败，请检查网络连接或仓库权限"
            print_info "尝试手动推送: cd $REPO_DIR && git push"
            return 1
        fi

    else
        print_warning "没有检测到文件变更，无需提交"
    fi
}

# 显示同步结果
show_result() {
    echo
    print_success "🎉 同步完成!"
    echo
    print_info "📊 同步统计:"
    echo "  - 仓库路径: $REPO_DIR"
    echo "  - 提交信息: $COMMIT_MSG"
    echo "  - 目标路径: $TARGET_PATH"
    echo
    print_info "🔗 查看你的代码: https://github.com/fremontzhang/$REPO_NAME"
    echo
    print_info "📋 仓库本地命令:"
    echo "  cd $REPO_DIR"
    echo "  git status"
    echo "  git log --oneline -5"
    echo
}

# 主函数
main() {
    print_info "开始GitHub同步..."
    echo "================================"

    check_repository
    check_target
    cd_to_repo
    sync_files
    git_operations
    show_result
}

# 错误处理
trap 'print_error "脚本执行失败"; exit 1' ERR

# 执行主函数
main "$@"