# Immich-Go 사용 가이드 🚀

`immich-go`는 공식 CLI의 한계를 보완하기 위해 만들어진 강력한 업로드 및 마이그레이션 도구입니다. 특히 대량의 사진(수십 GB 이상)이나 구글 포토 테이크아웃 데이터를 옮길 때 공식 도구보다 훨씬 안정적입니다.

---

## 1. 특징 및 장점

- **높은 안정성**: Go 언어로 작성되어 대용량 파일 전송 시 네트워크 끊김이나 메모리 부족 문제에 훨씬 강합니다. (`fetch failed` 에러 방지)
- **속도 최적화**: 멀티 쓰레드를 효율적으로 사용하여 업로드 속도가 빠릅니다.
- **다양한 소스 지원**: 로컬 폴더뿐만 아니라 Google Photos Takeout(ZIP), Immich 서버 간 이동 등을 지원합니다.

---

## 2. 설치 방법 (Linux)

### 방법 1: 바이너리 다운로드 (추천)
가장 빠르고 간편한 방법입니다.

1.  [**Releases 페이지**](https://github.com/simulot/immich-go/releases)에서 최신 버전의 `linux_amd64.tar.gz` 파일을 다운로드합니다.
2.  압축을 풀고 실행 권한을 부여합니다.
    ```bash
    # 다운로드 및 압축 해제 예시
    tar -xzf immich-go_Linux_x86_64.tar.gz
    chmod +x immich-go
    sudo mv immich-go /usr/local/bin/  # 어디서든 사용 가능하게 이동
    ```

### 방법 2: Docker 사용
시스템에 파일을 설치하고 싶지 않을 때 사용합니다.
```bash
docker run -it --rm -v $(pwd):/import ghcr.io/simulot/immich-go:latest <명령어>
```

---

## 3. 기본 사용법

### 인증 (API Key)
Immich 웹 UI > **Account Settings > API Keys**에서 키를 먼저 생성하세요.

### ✅ 로컬 폴더 업로드
가장 기본적인 업로드 방식입니다. 반드시 `from-folder` 서브 명령어를 포함해야 합니다.
```bash
immich-go -s http://<서버-IP>:2283 -k <내-API-KEY> upload from-folder /path/to/photos
```

### ✅ 구글 포토 테이크아웃(ZIP) 업로드
압축을 풀 필요 없이 ZIP 파일 그대로 지정하면 됩니다.
```bash
immich-go -s http://<서버-IP>:2283 -k <내-API-KEY> upload from-google-photos google-photos-takeout.zip
```

### ✅ 중복 건너뛰기 및 앨범 생성
```bash
# 폴더 이름을 앨범 이름으로 사용하여 자동 생성
immich-go -s http://<서버-IP>:2283 -k <내-API-KEY> upload from-folder --folder-as-album FOLDER /path/to/photos

# 전체 경로를 앨범 이름으로 사용하려면 PATH 입력
immich-go -s http://<서버-IP>:2283 -k <내-API-KEY> upload from-folder --folder-as-album PATH /path/to/photos
```

### ✅ 전체 하위 폴더 탐색 (Recursive)
`immich-go`는 기본적으로 모든 하위 폴더를 자동으로 탐색(Recursive)합니다. 별도의 옵션 없이 폴더 경로만 지정하면 됩니다.

### ✅ Immich 서버 설정(Storage Template) 사용
Immich 서버에 업로드되면, 파일은 서버의 **Administration > Settings > Storage Template** 설정에 따라 자동으로 분류되어 저장됩니다. (예: `2024/05/사진.jpg`)
`immich-go`로 업로드하는 모든 파일은 이 서버 규칙을 따르므로, 로컬의 폴더 구조와 상관없이 서버가 알아서 정리해 줍니다.

---

> [!IMPORTANT]
> **Connection Refused 에러 해결**:
> 만약 "connection refused" 에러가 발생한다면, 먼저 서버가 실행 중인지 확인하세요.
> ```bash
> cd immich
> docker compose ps  # 상태 확인
> docker compose up -d  # 꺼져 있다면 실행
> ```

## 4. 대용량 업로드 팁 (fetch 에러 방지)

공식 CLI에서 실패했던 파일들을 `immich-go`로 올릴 때는 다음 옵션을 곁들이면 더욱 좋습니다.

- **`-skip-verify`**: SSL 인증서 문제가 있을 경우 사용 (자가 서명 인증서 등)
- **`-dry-run`**: 실제로 올리기 전에 무엇이 올라갈지 테스트
- **`-workers 5`**: 동시에 처리할 작업 수 조절 (서버 사양에 맞게 조정)

---

> [!TIP]
> **권장 사항**: 10GB 이상의 대규모 데이터나 수천 장 이상의 사진을 처음 서버에 부을 때는 공식 `immich-cli`보다 `immich-go`를 최우선으로 고려하세요.
