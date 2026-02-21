---
title: Tool Schema Normalization (Gemini + OpenAI)
summary: Why OpenClaw normalizes tool schemas for provider compatibility, and how the pipeline works in code.
---

# Tool Schema Normalization (Gemini + OpenAI)

이 문서는 OpenClaw가 **단일 툴 + action 기반 스키마**를 유지하면서도, 왜/어떻게 **Gemini(OpenAI 포함)**에서 깨지지 않도록 정규화하는지 정리합니다.

핵심 결론:

- 단일 툴 구조 자체가 문제는 아닙니다.
- 실제 이슈는 provider별 **JSON Schema 수용 범위 차이**입니다.
- OpenClaw는 tool schema를 모델 호출 전에 정규화해 이 차이를 흡수합니다.

---

## 1) 배경: 왜 정규화가 필요한가?

OpenClaw는 `browser`, `cron`, `gateway`처럼 도메인별 단일 툴에서 `action`으로 동작을 분기합니다.

이 설계는 운영적으로 유리하지만, 스키마를 순진하게 구성하면 아래 충돌이 생깁니다.

- **OpenAI 계열 제약**
  - 함수 툴 스키마의 top-level이 `type: "object"`가 아니면 거절될 수 있음
  - root union(`anyOf`) 중심 스키마에서 실패 가능
- **Gemini/Cloud Code Assist 계열 제약**
  - 특정 JSON Schema 키워드/형태를 더 엄격하게 거절
  - nested `anyOf`/`oneOf`, `$ref`, 일부 validation keyword 등에서 400 계열 에러 발생 가능

따라서 OpenClaw는 **provider-neutral 내부 스키마**를 작성하되, 전송 직전에 provider-friendly 형태로 정리합니다.

---

## 2) 전체 파이프라인

1. 각 툴이 TypeBox 기반 스키마를 정의
2. 툴 목록 조립 시 `normalizeToolParameters`를 적용
3. 필요 시 union 병합/평탄화 + enum 복원
4. `cleanSchemaForGemini`로 Gemini 비호환 키워드 제거
5. 정규화된 스키마를 모델 호출에 전달

코드 기준 진입점:

- `src/agents/pi-tools.ts`
  - `const normalized = subagentFiltered.map(normalizeToolParameters);`

---

## 3) 핵심 코드 포인트

### 3.1 툴 조립 시 일괄 정규화

- 파일: `src/agents/pi-tools.ts`
- 포인트:
  - 모델에 넘기기 직전에 `normalizeToolParameters`를 모든 tool에 적용
  - 주석으로 OpenAI union 거절 이슈 명시

의미:

- 툴 구현자가 매번 provider별 수동 처리할 필요 없이,
- 공통 단계에서 정규화 품질을 통제합니다.

### 3.2 union 병합/평탄화 (`normalizeToolParameters`)

- 파일: `src/agents/pi-tools.schema.ts`
- 포인트:
  - provider quirks를 코드 주석으로 명시
  - top-level union(`anyOf`/`oneOf`)을 단일 object schema로 병합
  - action enum 같은 유용한 신호를 보존하도록 property merge

중요 로직:

- 이미 `type + properties`면 Gemini 클리닝만 적용
- `type` 누락 시 object 신호가 있으면 `type: "object"` 강제
- `anyOf/oneOf`가 있으면 변형들을 합성해 단일 스키마 생성

### 3.3 Gemini 클리닝 (`cleanSchemaForGemini`)

- 파일: `src/agents/schema/clean-for-gemini.ts`
- 포인트:
  - Gemini(Cloud Code Assist)에서 불안정한 키워드 집합 제거
  - `$ref` 로컬 참조를 가능한 경우 인라인으로 해소
  - literal union(anyOf/oneOf-of-literals)을 `enum`으로 평탄화
  - null variant stripping 등 provider 친화적 축소

제거/정리 대상 예시:

- `patternProperties`, `additionalProperties`
- `$schema`, `$id`, `$ref`, `$defs`, `definitions`
- `minLength`, `maximum`, `format`, `minItems` 등 다수 제약 키워드

---

## 4) 단일 툴(action 분기)와의 관계

OpenClaw는 provider 호환성을 위해 “툴을 여러 개로 분해”하지 않습니다.
대신 아래 전략을 씁니다.

1. **스키마는 평탄 object로 노출**
   - 예: `action`, `job`, `patch`, `request` 등 공통 필드 중심
2. **런타임에서 action별 요구사항 검증**
   - 예: `cron`에서 action에 따라 `job required`, `jobId required` 검사
3. **호환성 이슈는 정규화 레이어에서 해결**

즉 “API surface는 작게 유지 + 유효성은 런타임/정규화에서 강화”가 기본 철학입니다.

---

## 5) 대표 툴 구현 사례

### 5.1 Browser tool

- 파일: `src/agents/tools/browser-tool.schema.ts`
- 특징:
  - 주석으로 Vertex/Claude nested anyOf 이슈 명시
  - top-level object 스키마 강제
  - `request.kind` 기반 분기 구조

### 5.2 Cron tool

- 파일: `src/agents/tools/cron-tool.ts`
- 특징:
  - `job`/`patch`를 넓게 받고 런타임 normalize/validate
  - nested union-heavy gateway schema를 직접 노출하지 않음
  - action별 required를 switch에서 강하게 검사

---

## 6) 테스트 근거 (회귀 방지)

정규화/호환성은 테스트로 고정됩니다.

- `src/agents/pi-tools.create-openclaw-coding-tools.adds-claude-style-aliases-schemas-without-dropping.e2e.test.ts`
  - tool schema에서 `anyOf/oneOf/allOf` 제거 검증
  - enum 평탄화 검증
  - Gemini unsupported keyword 제거 검증
- `src/agents/openclaw-tools.sessions.e2e.test.ts`
  - Gemini 호환성 관련 number 타입 확인 (`integer` 대신 `number`)

실무적으로는 이 테스트들이 “provider가 바뀌어도 schema 품질이 깨지지 않는 안전망” 역할을 합니다.

---

## 7) 설계 트레이드오프

장점:

- 단일 툴 구조 유지(운영 단순성)
- provider별 차이를 중앙 정규화에서 흡수
- 기존 툴 API를 크게 깨지 않고 확장 가능

단점:

- 스키마 표현력이 일부 보수적으로 제한됨
- action별 엄격한 타입 안전은 런타임 검증 의존도가 높음
- 정규화 로직 복잡도가 증가

OpenClaw는 현재 “운영 안정성 + 멀티 provider 호환성”을 우선하여 이 트레이드오프를 선택합니다.

---

## 8) 유지보수 체크리스트

새 툴/스키마 추가 시 권장 사항:

1. top-level은 object로 유지
2. root union 스키마 직접 노출 지양
3. `action` enum + 평탄 필드 + 런타임 검증 패턴 준수
4. 정규화 후 스키마를 테스트로 고정
5. provider-specific 회피 로직은 `pi-tools.schema.ts`, `clean-for-gemini.ts`에 집중

---

## 9) 참고 파일 (빠른 이동)

- `src/agents/pi-tools.ts`
- `src/agents/pi-tools.schema.ts`
- `src/agents/schema/clean-for-gemini.ts`
- `src/agents/tools/browser-tool.schema.ts`
- `src/agents/tools/cron-tool.ts`
- `src/agents/pi-tools.create-openclaw-coding-tools.adds-claude-style-aliases-schemas-without-dropping.e2e.test.ts`
- `src/agents/openclaw-tools.sessions.e2e.test.ts`

---

필요하면 다음 단계로, 이 문서를 기반으로

- “단일 툴 + action 패턴 템플릿”
- “provider-safe schema 작성 규칙 (lint/checklist)”

두 문서도 이어서 분리해 드릴 수 있습니다.
