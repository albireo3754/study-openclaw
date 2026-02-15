# study-openclaw

OpenClaw 공식 소스코드를 공부/기록하는 개인 스터디 저장소입니다.

## 목적
- 기능별 소스 추적
- 동작 흐름 요약
- 설정/운영 팁 축적
- 법적/라이선스 체크 기록

## 구조
- `topics/`: 주제별 스터디 노트
  - `topics/discord-typing/`: Discord typing 동작 분석
  - `topics/_templates/`: 분업 템플릿
    - `WORK_UNIT_TEMPLATE.md`
    - `SESSION_SPLIT_PLAYBOOK.md`

## 작성 원칙
- 원문 코드 대량 복붙보다 **경로 + 핵심 라인 + 요약** 중심
- 필요 시 라이선스/저작권 체크 문서 동봉
- 재현 가능한 명령(`rg`, `nl`, `git`) 기록

## 현재 주제
1. Discord typing indicator
   - `topics/discord-typing/README.md`

## 분업 시작 방법 (OpenClaw)
1. `topics/_templates/WORK_UNIT_TEMPLATE.md`를 복사해 작업 단위 문서 생성
2. Work Unit의 `Sub-agent Prompt`를 채워 `sessions_spawn`으로 실행
3. `SESSION_SPLIT_PLAYBOOK.md` 순서대로 research/draft/verify 분리
4. main 세션에서 취합 후 커밋/푸시

## 참고
- Upstream: https://github.com/openclaw/openclaw
- License: MIT (upstream 기준)
