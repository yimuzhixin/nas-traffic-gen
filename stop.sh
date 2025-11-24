#!/bin/bash

# ==================== 配置 ====================
# 进程名称识别关键词（根据你的实际脚本名修改）
MAIN_PROCESS="nas.sh"      # 主脚本名称
CHILD_PROCESS="wget"       # 子进程名称
PID_FILE="nas.pid"         # 如果存在pid文件
# =============================================

echo "[$(date)] 正在关闭下载程序..."

# 第1步：尝试从pid文件关闭（最精确）
if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    PID=$(cat "$PID_FILE")
    echo "发现PID文件，终止主进程: $PID"
    kill "$PID" 2>/dev/null
    sleep 2
    
    # 如果还在运行，强制终止
    if kill -0 "$PID" 2>/dev/null; then
        echo "强制终止主进程..."
        kill -9 "$PID" 2>/dev/null
    fi
    
    rm -f "$PID_FILE"
fi

# 第2步：终止主脚本进程（匹配完整路径名）
echo "正在终止 $MAIN_PROCESS 进程..."
pkill -f "$MAIN_PROCESS" 2>/dev/null
sleep 1
pkill -9 -f "$MAIN_PROCESS" 2>/dev/null

# 第3步：清理所有wget子进程
echo "正在终止所有 $CHILD_PROCESS 子进程..."
pkill -f "$CHILD_PROCESS" 2>/dev/null
sleep 1
pkill -9 -f "$CHILD_PROCESS" 2>/dev/null

# 第4步：验证关闭结果
sleep 2
if pgrep -f "$MAIN_PROCESS" >/dev/null || pgrep -f "$CHILD_PROCESS" >/dev/null; then
    echo "⚠️ 警告：仍有进程残留！"
    echo "残留进程："
    ps aux | grep -E "$MAIN_PROCESS|$CHILD_PROCESS" | grep -v grep
else
    echo "✅ 所有下载程序已成功关闭"
fi

echo "--------------------------------------------------"
