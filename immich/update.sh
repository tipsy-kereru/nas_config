#!/bin/bash

# Emby Stack Update Script
# 이 스크립트는 모든 이미지의 최신 버전을 확인하고 업데이트합니다.

# 스크립트 파일이 위치한 디렉토리로 이동
cd "$(dirname "$0")"

echo "Step 1: 최신 이미지 다운로드 중..."
docker compose pull

echo "Step 2: 컨테이너 재시작 (이미지 업데이트 적용)..."
docker compose up -d

echo "Step 3: 사용되지 않는 오래된 이미지 정리 중..."
docker image prune -f

echo "업데이트 완료!"
