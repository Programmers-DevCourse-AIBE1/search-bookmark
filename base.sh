#!/bin/bash
set -euo pipefail

# 변수 정의
POM="pom.xml"
BACKUP="${POM}.backup"
NEW_SECTION_URL="https://gist.githubusercontent.com/Sewoni/4c733df853d4f3e4d0fbe6d6bdc93bda/raw/8ce420c88f10b60ed5c550219a07e0a059ecd480/gistfile1.txt"
DOCKERFILE_URL="https://gist.githubusercontent.com/Sewoni/8e4b115487e17bdf99198215d84bc8e4/raw/19611a719951519c8af590ddcc5d6b1f54db2630/gistfile1.txt"
GA_WORKFLOW_URL="https://gist.githubusercontent.com/Sewoni/b96ca30411daeb5792be9f99c52871c6/raw/fcdd16fc8a735a89678d78fd260bc142648690fd/gistfile1.txt"

# pom.xml 확인 및 백업
[ ! -f "$POM" ] && { echo "❌ $POM 파일 없음"; exit 1; }
cp "$POM" "$BACKUP"
echo "🔹 $POM → $BACKUP 백업 완료"

# 새 섹션 다운로드
curl -s "$NEW_SECTION_URL" -o new_section.txt || { echo "❌ 새 섹션 다운로드 실패"; cp "$BACKUP" "$POM"; exit 1; }
echo "🔹 새 섹션 다운로드 완료"

# pom.xml 내 <properties> ~ 첫 번째 </build> 교체 처리
if grep -q "<properties>" "$POM" && grep -q "</build>" "$POM"; then
  awk -v sec="new_section.txt" '
    BEGIN { while((getline line<sec)>0) ns=ns line "\n" }
    !f && /<properties>/ { print substr($0,1,index($0,"<properties>")-1) ns; f=1; next }
    f && /<\/build>/ { f=0; sub(/<\/build>/,""); print; next }
    !f
  ' "$POM" > pom_tmp.xml && mv pom_tmp.xml "$POM"
  echo "🔹 $POM 업데이트 완료"
else
  echo "❌ $POM 필수 태그 없음"; cp "$BACKUP" "$POM"; exit 1;
fi
rm new_section.txt

# 첫 번째 </build> 태그 제거
sed -i.bak '0,/<\/build>/s/<\/build>//' "$POM" && rm "$POM.bak"
echo "🔹 첫 번째 </build> 태그 제거 완료"

# .gitignore 업데이트
cat >> .gitignore << EOF

### dotenv ###
.env

### backup ###
*.backup
EOF
echo "🔹 .gitignore 업데이트 완료"

# Dockerfile 다운로드
curl -s "$DOCKERFILE_URL" -o Dockerfile || { echo "❌ Dockerfile 다운로드 실패"; exit 1; }
echo "🔹 Dockerfile 다운로드 완료"

# GitHub Actions 설정
mkdir -p .github/workflows
curl -s "$GA_WORKFLOW_URL" -o .github/workflows/gchr.yml && echo "🔹 GitHub Actions 설정 완료"

# git에 변경 사항 추가
git add "$POM" Dockerfile .gitignore .github/workflows/gchr.yml
echo "🔹 Git에 변경 사항 추가 완료"

echo "🔹 모든 작업 완료 🚀"