# Codex Prompt - Discord `#openclaw` Study Channel

이 프롬프트는 `#openclaw` 공부 채널에서, 스터디 문서를 정리/이동할 때 쓰는 간단 규칙입니다.

## 목적

- 스터디 중 작성한 문서를 `study-openclaw` 레포 구조로 이동한다.
- 문서 이동은 스크립트로 일관되게 처리한다.

## 기본 명령

```bash
cd ~/work/js/study-openclaw
scripts/import-openclaw-doc.sh <source-relative-path> <dest-relative-path>
```

## 예시 (툴 공부 문서 이동)

```bash
cd ~/work/js/study-openclaw
scripts/import-openclaw-doc.sh \
  topics/tool-schema-normalization/README.md \
  topics/tools-study/README.md
```

## 규칙

1. `source`/`dest`는 **레포 내부 상대경로**만 사용
2. 이동 후 `git status`로 변경 확인
3. 의미 있는 커밋 메시지로 커밋 + 푸시

## 커밋 예시

```bash
git add -A
git commit -m "docs: move tools study note to topics/tools-study"
git push
```

## 주의

- 이 스크립트는 upstream openclaw 원본 import용이 아니라,
  **study-openclaw 내부 문서 이동용(mv)** 입니다.
