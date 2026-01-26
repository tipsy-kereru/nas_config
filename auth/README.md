# 🔐 Auth & Infra Stack for Proxmox LXC

이 저장소는 **가벼우면서도 강력한 사용자 인증, DNS, 리바스 프록시** 환경을 구성하기 위한 Docker Compose 설정을 포함하고 있습니다. 특히 **Proxmox LXC (2GB RAM / 2GB Swap)** 환경에 최적화되어 있습니다.

## 🚀 서비스 구성
| 서비스 | 용도 | 특징 |
| :--- | :--- | :--- |
| **Blocky** | DNS 서버 | 초경량, 광고 차단, 커스텀 도메인 설정 가능 |
| **Caddy** | Reverse Proxy | 자동 HTTPS (TLS), 간결한 설정, 높은 성능 |
| **Authelia** | 인증 (SSO) | SQLite 기반 경량 인증체계, 2FA 지원 |
| **CrowdSec** | 보안 (IPS) | 침입 탐지 및 차단 (WAF 역할 대행) |
| **Vaultwarden** | 패스워드 매니저 | Bitwarden의 경량 Rust 구현체 |

---

## 🛠 설치 전 필수 지침

### 1. LXC 컨테이너 설정 (Proxmox 호스트)
LXC 내부에서 Docker와 이 스택이 정상 작동하려면 다음 설정이 필요합니다.
*   **Nesting:** `Enabled` (Docker 구동에 필수)
*   **Option:** `Unprivileged: No` 또는 적절한 ID Mapping (Bouncer 및 Watchtower의 소켓 접근용)
*   **Resources:** 최소 2GB RAM / 2GB Swap 권장

### 2. 포트 53 점유 해결 (Blocky용)
대부분의 리눅스 배포판은 `systemd-resolved`가 53번 포트를 선점하고 있습니다.
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

---

## ⚡ 최적화 가이드

### 1. SQLite WAL (Write-Ahead Logging) 모드 적용
서비스 동시성과 속도를 높이기 위해 Authelia의 DB 형식을 WAL 모드로 변경하는 것이 좋습니다.
1.  명령어 실행 (Authelia 첫 실행 후):
    ```bash
    # Authelia 데이터 경로의 db.sqlite3 파일 대상
    sqlite3 ./data/authelia/db.sqlite3 "PRAGMA journal_mode=WAL;"
    ```
2.  **Vaultwarden**은 기본적으로 WAL 모드가 활성화되어 있습니다.

### 2. 저장소 권한
SQLite 잠금 이슈를 방지하기 위해 컨테이너의 데이터 파일은 반드시 **컨테이너 로컬 SSD 저장소**에 위치시켜야 합니다 (NFS/CIFS 금지).

---

## 🚦 시작하기

1.  **환경 변수 설정:** `.env` 파일(필요시)을 생성하고 필요한 비밀번호와 도메인을 설정합니다.
2.  **데이터 디렉토리 생성:**
    ```bash
    mkdir -p data/{blocky,caddy,authelia,crowdsec,vaultwarden} logs/{caddy,authelia}
    ```
3.  **실행:**
    ```bash
    docker compose up -d
    ```

---

## 🛡 관리 및 보안 지침

*   **가입 제한:** Vaultwarden 설치 직후 계정을 생성한 후, `SIGNUPS_ALLOWED=false`로 변경하여 외부 가입을 차단하세요.
*   **보안 업데이트:** Watchtower가 24시간마다 이미지를 체크하여 자동으로 최신 상태를 유지합니다.
*   **차단 확인:** `docker exec crowdsec cscli decisions list` 명령어로 현재 차단된 IP 목록을 확인할 수 있습니다.

---

> [!IMPORTANT]
> **Swappiness 설정:** 2GB RAM 환경에서는 메모리가 부족할 때 시스템이 멈추지 않도록 호스트의 `swappiness` 값을 `10` 정도로 낮게 설정하는 것이 좋습니다.
