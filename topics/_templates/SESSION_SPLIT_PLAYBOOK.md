# Session Split Playbook

## 목적
OpenClaw 메인 세션 1개 + 서브 세션 N개로 작업을 병렬화할 때 쓰는 운영 규칙입니다.

## 역할 분리
- **main (orchestrator)**
  - 작업 쪼개기
  - 서브 세션 생성/취합
  - 최종 머지/커밋
- **sub-agent (executor)**
  - 지정 범위만 수행
  - 중간 결정은 문서로 기록

## 권장 라벨
- `research-<topic>`
- `draft-<topic>`
- `verify-<topic>`

예: `research-discord-typing`, `draft-discord-typing`, `verify-discord-typing`

## 표준 워크플로우
1. Work Unit 작성 (`topics/_templates/WORK_UNIT_TEMPLATE.md` 복사)
2. `sessions_spawn`으로 research 생성
3. 결과 기반으로 draft 생성
4. verify 세션으로 사실 검증
5. main에서 반영 + 커밋 + push

## 실패/충돌 처리
- 같은 파일 동시 수정 금지
- 충돌 시 main이 단일 기준으로 수동 병합
- 서브 세션이 범위 외 수정하면 폐기하고 재실행

## 체크리스트
- [ ] 각 서브 세션 목표가 1문장으로 명확한가?
- [ ] 산출물 경로가 겹치지 않는가?
- [ ] 최종 반영 전 사실검증 세션을 돌렸는가?
