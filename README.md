# OpenClaw Discord Typing Study

이 문서는 `~/work/js/openclaw` 소스 기준으로, Discord 입력중(typing) 동작 경로를 추적한 스터디 노트입니다.

## 핵심 요약

- Discord inbound 처리 중 reply dispatcher를 만들 때 `onReplyStart`에 typing 시작 훅을 연결합니다.
- 실제 Discord API 호출은 `sendTyping()`에서 채널 객체의 `triggerTyping()`을 호출합니다.
- 타이핑 루프 기본 주기는 **6초**(`typingIntervalSeconds = 6`)입니다.
- 타이핑 TTL 기본값은 **2분**(`typingTtlMs = 120000`)으로, 장시간 지연 시 무한 루프를 방지합니다.

## 소스 경로 (핵심 파일)

1. Discord 메시지 처리에서 typing 시작 훅 연결
- `src/discord/monitor/message-handler.process.ts`
- 참고 라인: 357~391

```ts
const { dispatcher, replyOptions, markDispatchIdle } = createReplyDispatcherWithTyping({
  ...,
  onReplyStart: createTypingCallbacks({
    start: () => sendTyping({ client, channelId: typingChannelId }),
    ...
  }).onReplyStart,
});
```

2. Discord 채널 typing 실제 호출
- `src/discord/monitor/typing.ts`
- 참고 라인: 3~10

```ts
export async function sendTyping(params: { client: Client; channelId: string }) {
  const channel = await params.client.fetchChannel(params.channelId);
  if (!channel) return;
  if ("triggerTyping" in channel && typeof channel.triggerTyping === "function") {
    await channel.triggerTyping();
  }
}
```

3. 공통 typing 컨트롤러(루프/TTL)
- `src/auto-reply/reply/typing.ts`
- 참고 라인:
  - 기본값: 25~26 (`typingIntervalSeconds = 6`, `typingTtlMs = 2 * 60_000`)
  - 루프: 155~158 (`setInterval`)
  - TTL 종료: 90~96

4. 어떤 이벤트에서 typing을 시작/연장하는지
- `src/auto-reply/reply/typing-mode.ts`
- 참고 라인:
  - 실행 시작 즉시: 66~71
  - 텍스트 델타: 83~103
  - 툴 시작 시 즉시/연장: 116~128

## 동작 흐름

1. Discord 메시지 수신
2. `createReplyDispatcherWithTyping()` 구성 시 `onReplyStart` 연결
3. reply 진행 중 `sendTyping()` 호출
4. typing 컨트롤러가 6초 간격으로 재신호
5. reply 완료 + 디스패처 idle 시 cleanup
6. TTL(2분) 초과 시 강제 cleanup

## 레이트리밋 메모

Discord는 고정 수치를 하드코딩하지 말고, 응답 헤더(`X-RateLimit-*`)와 `retry_after`를 따르라고 권장합니다.
공식 문서 기준 `/typing`의 고정 숫자 limit 값은 공개된 상수 형태로 보장되지 않습니다.

## 재현용 탐색 명령

```bash
cd ~/work/js/openclaw
rg -n "sendTyping\(|createReplyDispatcherWithTyping|typingIntervalSeconds|typingTtlMs" src
```

## 라이선스/저작권 검토 요약

- OpenClaw 저장소 `LICENSE`는 MIT License입니다.
- MIT는 복제/수정/배포/상업적 이용을 허용합니다.
- 단, 소프트웨어의 복사본 또는 상당 부분에는 **저작권 고지 + MIT 라이선스 문구 포함**이 필요합니다.
- 이 스터디 레포는 요약/분석 위주라 안전하며, 원문 코드를 크게 복사할 경우 LICENSE/저작권 고지를 반드시 함께 포함하세요.

(원문 라이선스 확인: `~/work/js/openclaw/LICENSE`)
