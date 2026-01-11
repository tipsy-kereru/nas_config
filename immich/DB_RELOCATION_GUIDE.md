# PostgreSQL 데이터 디렉토리 이동 가이드 📂

이 가이드는 Immich 데이터베이스(`postgres`) 폴더를 더 용량이 큰 드라이브나 다른 위치로 안전하게 옮기는 방법을 설명합니다.

---

## 1. 사전 준비

작업을 시작하기 전, 데이터 손상을 방지하기 위해 컨테이너를 정지해야 합니다.

```bash
cd immich
docker compose down
```

---

## 2. 폴더 이동

`mv` 명령어를 사용하여 기존 데이터를 새 위치로 물리적으로 이동합니다.

```bash
# 예시: 현재 폴더의 postgres를 새로운 경로로 이동
mv ./postgres /media/data/immich-db
```

---

## 3. 설정 업데이트

`immich/.env` 파일을 수정하여 Immich가 새로운 경로를 인식하도록 합니다.

1. `immich/.env` 파일을 엽니다.
2. `DB_DATA_LOCATION` 항목을 찾아 이동한 **새 실제 경로**로 수정합니다.

```env
# 변경 전
DB_DATA_LOCATION=./postgres

# 변경 후 (실제 경로에 맞게 수정)
DB_DATA_LOCATION=/media/data/immich-db
```

---

## 4. 권한 확인 (중요)

새로운 위치로 옮긴 후, 도커 컨테이너가 해당 폴더에 쓸 수 있도록 소유권 권한을 확인해야 합니다.

```bash
# PUID/PGID가 1000인 경우 (기본값)
sudo chown -R 1000:1000 /media/data/immich-db
```

---

## 5. 실행 및 확인

설정이 완료되었으면 컨테이너를 다시 시작합니다.

```bash
docker compose up -d
```

실행 후 Immich 웹 UI에 정상적으로 접속되고 이전 사진들이 잘 보이는지 확인하세요.

---

> [!CAUTION]
> **주의**: 데이터베이스 폴더를 이동하는 작업은 중요하므로, 이동 전 반드시 해당 폴더를 백업해 두는 것을 권장합니다.
