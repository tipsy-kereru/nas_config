# Immich CLI 사용 가이드 📸

Immich CLI는 수천 장의 사진과 비디오를 서버로 한꺼번에 업로드할 때 매우 유용한 도구입니다.

---

## 1. 실행 방법

별도의 설치 과정 없이 `npx`를 사용하거나 Docker를 통해 실행할 수 있습니다.

- **npx 사용 (추천):**
  ```bash
  npx @immich/cli --help
  ```

- **Docker 사용:**
  ```bash
  docker run -it --rm ghcr.io/immich-app/immich-cli:latest --help
  ```

---

## 2. 로그인 (인증)

업로드 전 서버 주소와 API Key를 이용해 인증이 필요합니다.
*(API Key 생성: Immich 웹 UI > Account Settings > API Keys)*

```bash
npx @immich/cli login http://<서버-IP>:2283/api <내-API-KEY>
```
성공하면 인증 정보가 저장되어 다음부터는 다시 로그인할 필요가 없습니다.

---

## 3. 주요 업로드 명령어

### ✅ 폴더 전체 업로드 (재귀적)
특정 폴더와 그 하위 폴더의 모든 파일을 업로드합니다.
```bash
npx @immich/cli upload --recursive /path/to/photos
```

### ✅ 폴더 이름을 자동 앨범으로 지정
`--album` 옵션을 쓰면 폴더 구조를 유지하며 앨범을 자동으로 만들어줍니다.
```bash
npx @immich/cli upload --recursive --album /path/to/photos
```

### ✅ 특정 앨범에 직접 업로드
```bash
npx @immich/cli upload --album-name "2024년 뉴질랜드 여행" --recursive /path/to/photos
```

### ✅ 업로드 미리보기 (Dry Run)
실제로 올리기 전에 어떤 파일이 올라갈지 확인해볼 때 사용합니다.
```bash
npx @immich/cli upload --dry-run --recursive .
```

---

## 4. 스토리지 최적화 (공간 확보) 💾

업로드 성공 후 로컬 파일을 삭제하거나, 이미 서버에 있는 중복 파일을 찾아 지울 수 있습니다.

- **`--delete`**: 업로드 성공한 파일을 로컬에서 즉시 삭제
- **`--delete-duplicates`**: 서버에 이미 존재하는 로컬 파일을 삭제 (공간 확보용)

```bash
# 한 번에 1개씩 안전하게 업로드하고, 성공하면 로컬 사진 삭제
npx @immich/cli@latest upload -u <서버URL> -k <API키> --delete -c 1 --recursive /media/storage/photos
```

---

## 5. 유용한 옵션 및 팁

- **`--ignore`**: 특정 파일 패턴(예: `*.json`, `*.txt`)을 제외할 때 사용합니다.
- **`--skip-hash`**: 중복 확인 과정을 건너뛰고 업로드 속도를 높일 수 있지만 권장하지 않습니다.
- **`immich-go`**: 구글 포토 테이크아웃 데이터 마이그레이션이 목적이라면 [immich-go](https://github.com/simulot/immich-go)를 사용하세요.

---

## 5. 트러블슈팅: `TypeError: fetch failed`

업로드 중 `TypeError: fetch failed` 에러가 발생하며 업로드가 중단된다면 다음 방법들을 시도해 보세요.

### ① 동시 업로드 제한 (`-c` 옵션)
서버(LXC/Docker)의 리소스가 부족할 때 자주 발생합니다. 동시 업로드 프로세스 수를 줄이면 안정성이 높아집니다.
```bash
# 한 번에 2개씩만 업로드하도록 제한
npx @immich/cli upload -c 2 --recursive /path/to/photos
```

### ② 서버 주소를 IP로 변경
DNS 문제나 프록시 지연으로 연결이 끊길 수 있습니다. `immich login` 시 도메인 주소 대신 **서버의 내부 IP 주소**를 직접 사용해 보세요.
- 예: `http://192.168.1.100:2283/api`

### ③ 서버 작업 일시 중지
사진이 올라가는 즉시 Immich 서버는 섬네일 생성, 얼굴 인식 등의 작업을 시작합니다. 이 작업들이 CPU를 많이 점유하면 업로드 응답이 늦어질 수 있습니다.
- **해결책**: Immich 웹 UI > **Administration > Job Settings**에서 `Thumbnail Generation`, `Library`, `Machine Learning` 등의 작업을 잠시 **PAUSE** 하고 업로드를 진행하세요.

### ④ 리버스 프록시 설정 (Nginx 등)
만약 Nginx나 프록시 서버를 사용 중이라면, 큰 파일 업로드 시 타임아웃이 발생할 수 있습니다. Nginx 설정에서 다음 값을 충분히 크게(예: 50G) 잡아주세요.
```nginx
client_max_body_size 50000M;
proxy_read_timeout 600s;
proxy_send_timeout 600s;
```

---

## 6. 더 강력한 대안: `immich-go`

만약 공식 CLI가 계속 실패한다면, 개발자 커뮤니티에서 대용량 업로드용으로 훨씬 안정적이라고 평가받는 [**immich-go**](https://github.com/simulot/immich-go) 사용을 강력히 권장합니다. Go 언어로 작성되어 Node.js의 네트워크 한계를 넘어서며, 특히 테이크아웃 데이터나 수십 GB 단위의 업로드에 매우 강합니다.

### immich-go 주요 장점:
- 네트워크 끊김 시 더 똑똑한 재시도 전략
- 메모리 사용량 최적화 (4GB RAM 환경에 유리)
- 스택 처리(RAW+JPG) 및 구글 포토 마이그레이션 완벽 지원

---

> [!TIP]
> **중단된 업로드 재개**: 업로드가 실패해도 다시 명령어를 실행하면 Immich가 이미 올라간 파일은 건너뛰고 **누락된 파일만 자동으로 골라서 업로드**합니다. 안심하고 다시 시도하세요. 특히 `--delete-duplicates` 옵션과 함께 쓰면 이미 올라간 파일을 지우며 공간을 확보할 수 있습니다.
