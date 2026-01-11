# 미디어 서버 설정 (NAS Config)

이 저장소는 Docker Compose를 이용한 개인 미디어 서버 및 사진 관리 시스템(Immich) 설정 파일들을 포함하고 있습니다.

## 🚀 포함된 서비스

### 1. 전용 미디어 스택 (`emby/`)
- **Emby**: 미디어 스트리밍 서버
- **Prowlarr**: 인덱서 매니저
- **Sonarr**: TV 시리즈 자동화
- **Radarr**: 영화 자동화
- **Bazarr**: 자막 관리
- **ByParr**: Cloudflare 우회 (FlareSolverr 대체)
- **qBittorrent**: 다운로드 클라이언트

### 2. 사진 관리 스택 (`immich/`)
- **Immich**: 고성능 자가 호스팅 사진/비디오 관리 솔루션 (Google Photos 대체)
  - [CLI 사용 가이드](file:///home/kereru/Development/media-server-settings/immich/CLI_GUIDE.md): 대량 업로드를 위한 CLI 도구 설명
  - [Immich-Go 사용 가이드](file:///home/kereru/Development/media-server-settings/immich/IMMICH_GO_GUIDE.md): 더욱 강력한 대안 도구 사용법
  - [DB 위치 변경 가이드](file:///home/kereru/Development/media-server-settings/immich/DB_RELOCATION_GUIDE.md): 데이터베이스 저장 폴더 이동 방법

---

## 🛠 설치 및 사용 방법

### 1. 사전 준비
- Docker 및 Docker Compose 플러그인이 설치되어 있어야 합니다.
- 자신의 `PUID`와 `PGID`를 확인하려면 터미널에서 `id` 명령어를 입력하세요.

### 2. 설정 파일 작성
각 스택 폴더(`/emby`, `/immich`)에서 템플릿 파일을 복사하여 실제 설정 파일을 만듭니다.

#### Emby 스택 설정
```bash
cd emby
cp .env.example .env
```
- `.env` 파일을 열어 `MEDIA_ROOT`를 실제 미디어가 저장된 경로로 수정하세요.
- 필요에 따라 포트 번호를 수정하세요.

#### Immich 스택 설정
```bash
cd immich
cp .env.example .env
```
- `.env` 파일을 열어 `DB_PASSWORD`를 데이터베이스에서 사용할 비밀번호로 수정하세요.

### 3. 컨테이너 실행
각 폴더에서 다음 명령어를 실행합니다.

```bash
docker compose up -d
```

### 4. 업데이트 방법
이미지를 최신 버전으로 업데이트하려면 각 폴더에 제공된 스크립트를 실행하세요.
```bash
# Emby 스택 업데이트
cd emby && ./update.sh

# Immich 스택 업데이트
cd immich && ./update.sh
```
*이 스크립트는 최신 이미지를 다운로드하고, 컨테이너를 재시작한 뒤 오래된 이미지를 정리합니다.*

---

## 🔒 보안 주의사항 (중요)

> [!CAUTION]
> **민감한 파일 노출 금지**
> `.env` 파일과 `db_password.txt` 파일에는 비밀번호 및 시스템 경로 등 민감한 정보가 포함되어 있습니다. 
> 이 파일들은 절대 GitHub과 같은 공용 저장소에 직접 올리지 마세요. (현재 `.gitignore` 설정으로 방지되어 있습니다.)

- **환경 변수 관리**: 각 스택은 `.env` 파일을 통해 데이터베이스 비밀번호와 파일 저장 경로를 관리합니다.
- **네트워크**: `media-network`라는 이름의 전용 브리지 네트워크를 통해 서비스 간 통신이 이루어집니다.

---

## 📂 디렉토리 구조
```text
.
├── emby/
│   ├── docker-compose.yml
│   └── .env.example
├── immich/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── update.sh
```
