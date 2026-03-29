#!/bin/bash
set -e

# 保存当前分支
CURRENT=$(git branch --show-current)
git branch --show-current

# 更新 main
git checkout main
git branch --show-current

UPSTREAM_URL="https://github.com/agentscope-ai/CoPaw.git"
# 检查并添加 upstream（如果不存在）
if ! git remote | grep -q "^upstream$"; then
    echo "添加 upstream: $UPSTREAM_URL"
    git remote add upstream "$UPSTREAM_URL"
fi

echo "=== 同步上游 copaw 更新 ==="
git fetch upstream
git merge upstream/main --no-edit
NOW_TIME=`date`
git add .
git commit -m 'fetch from copaw at ${NOW_TIME}'
git push origin main

echo "=== 同步完成 ==="

echo "Then, you should run command:"
echo "git checkout develop"
echo "git merge main --no-edit"
echo "or"
echo "git rebase main"
git checkout develop
git merge main --no-edit || {
    echo "⚠️  有冲突，请手动解决"
    exit 1
}
echo "Remember exec command by yourself:"
echo "git checkout develop"
echo "git push origin develop"

#main 保持干净  只跟踪上游，不直接提交业务代码
#功能分支开发   所有自定义代码在 feature/* 分支
#频繁同步       上游更新时立即合并，避免冲突堆积
#冲突早解决     小步快跑，不要攒大量差异
