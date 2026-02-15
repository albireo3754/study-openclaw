# Work Unit Template (OpenClaw 분업용)

> 목적: 하나의 주제를 여러 서브 세션(서브 에이전트)으로 안전하게 분업하기 위한 템플릿

## 0) Work Unit 메타
- `work_id`: wu-YYYYMMDD-###
- `topic`: (예: discord-typing / memory-cron / auto-reply)
- `owner_session`: main
- `status`: todo | doing | review | done
- `created_at`:
- `due`:

## 1) 목표(Goal)
- 이번 단위 작업에서 **딱 무엇을 끝낼지** 1~3줄로 작성

## 2) 범위(Scope)
### In
- 

### Out
- 

## 3) 입력/참고(Source of Truth)
- upstream repo: `~/work/js/openclaw`
- 참고 파일/경로:
  - 
- 참고 이슈/PR/문서:
  - 

## 4) 실행 지시문(Sub-agent Prompt)
아래 블록을 그대로 `sessions_spawn`에 넣어 실행:

```text
You are sub-agent <label> for work_id=<work_id>.

Objective:
- <구체 작업 1>
- <구체 작업 2>

Constraints:
- Work ONLY in /Users/pray/.openclaw/workspace/openclaw-discord-typing-study
- Do not change unrelated files.
- Prefer concise diffs.
- Record findings with file paths + line numbers when possible.

Deliverables:
1) Updated docs/files
2) Short summary (what changed / why)
3) Open questions (if any)
```

## 5) 산출물(Deliverables)
- 필수:
  - [ ] 문서/코드 변경
  - [ ] 근거 경로 + 라인
  - [ ] 요약
- 선택:
  - [ ] 다이어그램
  - [ ] 재현 명령

## 6) 완료 기준(Definition of Done)
- [ ] 범위 내 작업만 반영
- [ ] 재현 명령 동작 확인
- [ ] README/인덱스 링크 업데이트
- [ ] 커밋 완료

## 7) 실행 로그
- spawned session:
- key outputs:
- review notes:

---

## 빠른 분업 패턴 (추천)

### 패턴 A: 탐색/정리/검증 3분할
1. `research` 세션: 소스 경로/핵심 라인 수집
2. `writer` 세션: 문서 초안 작성
3. `checker` 세션: 사실검증 + 누락 체크

### 패턴 B: 기능별 병렬
- `discord-*`, `memory-*`, `cron-*`처럼 기능 단위로 분리

### 패턴 C: 큰 주제의 단계 분리
- phase1 조사 → phase2 문서화 → phase3 개선안
