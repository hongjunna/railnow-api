<p align="center">
  <a href="https://railnow.runvia.app">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="assets/railnow-logo-dark.svg">
      <img src="assets/railnow-logo-light.svg" alt="RailNow" width="320">
    </picture>
  </a>
</p>

<p align="center">
  <b>수도권 전철의 실시간 열차 위치를 제공하는 무료 REST API</b><br>
  지금, 열차는 어디에?
</p>

<p align="center">
  <a href="https://railnow.runvia.app/api/docs"><img alt="API 문서" src="https://img.shields.io/badge/docs-Swagger-006E51"></a>
  <a href="openapi/openapi.en.json"><img alt="OpenAPI 3.0.3" src="https://img.shields.io/badge/OpenAPI-3.0.3-6BA539"></a>
  <img alt="API 버전" src="https://img.shields.io/badge/API-v2.2.0-006E51">
  <a href="https://railnow.runvia.app/developer"><img alt="무료 API 키" src="https://img.shields.io/badge/API%20key-free-C9F27B"></a>
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="https://railnow.runvia.app">웹 서비스</a> ·
  <a href="https://railnow.runvia.app/developer">개발자 센터</a> ·
  <a href="https://railnow.runvia.app/api/docs">API 문서</a>
</p>

---

RailNow는 수도권 전철의 모든 열차를 추적합니다. 서울시 실시간 도착정보를 수 분 간격으로 수집하고 공식 시각표로 보정해 열차별 현재 위치, 다음 역, 지연(초 단위), 행선지를 제공합니다. 역별 도착 정보, 시각표, 역간 거리, 실측 구간 소요시간 통계도 조회할 수 있습니다.

이 저장소에는 공개 문서, OpenAPI 명세, 예제 코드가 있습니다. 버그 제보와 기능 요청은 이슈로 남겨 주세요.

## 주요 기능

- **실시간 열차 위치**: 노선의 운행 중인 모든 열차, 또는 열차 번호로 한 열차의 위치를 시각표 기준 초 단위로 보정해 제공합니다.
- **역별 도착 정보**: 역 앞 5개 역 이내에 있는 열차를 방향별로 보여주고 도착까지 남은 시간을 초 단위로 알려줍니다.
- **시각표**: 열차의 전체 역별 시각표를 평일·토요일·공휴일 기준으로 제공합니다.
- **역 정보**: 역 이름이나 초성(`ㄱㄴ` → 강남)으로 검색하고 환승 노선, 좌표, 주소, 영문 역명을 조회합니다.
- **거리와 소요시간**: 역간 거리, 시각표 기준 소요시간, 시간대별 실측 소요시간을 제공합니다.
- **영어 응답**: 요청에 `lang=en`을 붙이면 역명·상태·메시지를 영어로 받습니다.

## 시작하기

**1. 무료 API 키 발급.** [개발자 센터](https://railnow.runvia.app/developer)에서 Google로 로그인하고 키(`jl_...`)를 발급합니다.

**2. API 호출.**

```bash
export RAILNOW_API_KEY="jl_발급받은_키"

# 실시간 추적을 지원하는 노선 목록
curl -H "X-API-Key: $RAILNOW_API_KEY" \
  "https://railnow.runvia.app/api/v1/train/lines"

# 지금 2호선을 운행 중인 모든 열차
curl -H "X-API-Key: $RAILNOW_API_KEY" \
  "https://railnow.runvia.app/api/v1/train/lines/1002/trains"
```

**3. 출처 로고 표시.** RailNow 데이터를 보여주는 화면에는 로고를 반드시 표시해야 합니다. [출처 표기](#출처-표기)를 참고하세요.

[`examples/`](examples)에 [curl](examples/curl/quickstart.sh), [JavaScript](examples/javascript/quickstart.mjs), [Python](examples/python/quickstart.py) 예제가 있습니다.

## 엔드포인트

기본 주소는 `https://railnow.runvia.app`입니다. 모든 엔드포인트는 `GET`이며 `X-API-Key` 헤더가 필요합니다.

### 열차

| 엔드포인트 | 설명 |
|---|---|
| `/api/v1/train/lines` | 실시간 열차 추적을 지원하는 노선 목록 |
| `/api/v1/train/lines/{lineId}/trains` | 노선의 운행 중인 모든 열차 위치. `direction`(`UP`/`DOWN`), `trainType`(`EXPRESS`/`LOCAL`)으로 거를 수 있습니다. |
| `/api/v1/train/{trainNo}?lineId=` | 한 열차의 현재 위치, 다음 역, 지연, 운행 이력 |
| `/api/v1/train/{trainNo}/timetable?lineId=` | 한 열차의 전체 역별 시각표 |
| `/api/v1/line-map/{lineId}` | 노선도를 그리기 위한 구간 정보 |

### 역

| 엔드포인트 | 설명 |
|---|---|
| `/api/v1/station/lines` | 전체 노선 목록 |
| `/api/v1/station/search?q=` | 역 이름·초성 검색. `lineId`로 노선을 거를 수 있습니다. |
| `/api/v1/station/{keyword}` | 역 ID나 이름으로 역 상세 조회 |
| `/api/v1/station/{stationId}/board` | 역별 실시간 도착 정보 |
| `/api/v1/station/{stationId}/transfers` | 환승 노선 |
| `/api/v1/station/distances` | 역간 거리와 시각표 기준 소요시간 |

### 시각표·통계·현황

| 엔드포인트 | 설명 |
|---|---|
| `/api/v1/timetable/` | 열차 번호·노선·역·날짜로 시각표 검색 |
| `/api/v1/analytics/segment-travel-stats` | 요일 유형·시간대별 구간 실측 소요시간 통계 |
| `/api/v1/data-status/` | 노선별 데이터 커버리지와 수집 신선도 |
| `/api/v1/data-status/{lineId}` | 한 노선의 상세 데이터 현황 |
| `/api/v1/realtime/all` | 서울 지하철 실시간 도착정보 원본 스냅샷 |
| `/api/v1/realtime/train/{trainNo}` | 한 열차의 실시간 원본 기록 |

전체 파라미터와 응답 필드는 [API 문서](https://railnow.runvia.app/api/docs)에서 확인하고 직접 호출해 볼 수 있습니다. `/api/v1/calibration/*`은 더 이상 권장하지 않으므로 `/api/v1/train/*`을 사용하세요.

### 공통 파라미터

| 파라미터 | 설명 |
|---|---|
| `lang` | `en`이면 값을 영어로(`Arrived`, `Up`, `Gangnam`) 돌려줍니다. 생략하면 한국어(`도착`, `상행`, `강남`)입니다. |
| `date` | 운행일(`YYYY-MM-DD`). 생략하면 한국 시간 기준 오늘입니다. |
| `simple` | `true`이면 상태를 도착/이동 중 두 가지로 줄입니다. |
| `detail` | `true`이면 `progress`와 `nextAction`을 추가합니다. |
| `smooth` | `true`이면 실시간 갱신 사이의 위치를 부드럽게 보정합니다. |

## 노선 ID

| ID | 노선 | ID | 노선 |
|---|---|---|---|
| `1001` | 1호선 | `1063` | 경의중앙선 |
| `1002` | 2호선 | `1065` | 공항철도 |
| `1003` | 3호선 | `1067` | 경춘선 |
| `1004` | 4호선 | `1075` | 수인분당선 |
| `1005` | 5호선 | `1077` | 신분당선 |
| `1006` | 6호선 | `1081` | 경강선 |
| `1007` | 7호선 | `1092` | 우이신설선 |
| `1008` | 8호선 | `1093` | 서해선 |
| `1009` | 9호선 | `1094` | 신림선 |
| `1032` | GTX-A | | |

실시간 추적 노선의 최신 목록은 `/api/v1/train/lines`로 확인하세요. 공개 시각표가 없는 노선(우이신설선, GTX-A, 신분당선, 신림선)은 `mode: "RAW"`로 지연 보정 없이 실시간 원본 위치만 제공합니다.

## 열차 모드

`/api/v1/train/{trainNo}`의 `mode`는 위치를 어떻게 구했는지 알려줍니다.

| `mode` | 의미 |
|---|---|
| `LIVE` | 실시간 데이터로 보정한 위치 |
| `ESTIMATED` | 실시간 데이터가 없어 시각표로 추정한 위치 |
| `SCHEDULED` | 아직 출발역을 떠나지 않은 열차 |
| `ENDED` | 종착역에 도착해 운행을 마친 열차 |
| `RAW` | 시각표가 없는 노선. 실시간 원본 위치만 제공 |

## 인증과 요청 한도

- 키는 `X-API-Key` 헤더로 보냅니다.
- 키마다 **시간당 500회**, **하루 5,000회**까지 호출할 수 있으며, 키를 발급한 시각부터 1시간·24시간마다 초기화됩니다.
- 키 유효기간은 1년이며 만료 1개월 전부터 연장할 수 있습니다.
- 키에 승인 도메인을 지정하면 다른 출처의 브라우저 요청을 거부합니다.

| 상태 코드 | 응답 본문 | 원인 |
|---|---|---|
| `401` | `{"error":"Invalid or expired API key"}` | 키가 없거나 틀렸거나 만료됨 |
| `403` | `{"error":"Domain is not allowed for this API key"}` | 승인 도메인이 아닌 곳에서 요청함 |
| `429` | `{"error":"..."}` | 요청 한도 초과. `Retry-After` 헤더의 초만큼 기다린 뒤 다시 요청하세요. |

RapidAPI 마켓에서도 구독할 수 있습니다. RapidAPI에서 구독했다면 개발자 센터에서 계정을 연결해 사용량과 요청 기록을 확인하세요.

## 출처 표기

**RailNow 데이터를 쓰는 모든 서비스는 데이터를 보여주는 화면에 로고를 넣어 제공자를 표시해야 합니다.** "Provided by" 로고를 권장합니다. 배경에 맞는 로고를 고르고, 가능하면 https://railnow.runvia.app 으로 연결해 주세요. 로고의 비율과 색은 바꾸지 마세요.

<p>
  <a href="https://railnow.runvia.app"><img src="assets/railnow-provided-by-universal.svg" alt="Provided by RailNow" width="220"></a>
</p>

```html
<a href="https://railnow.runvia.app" target="_blank" rel="noopener">
  <img src="https://railnow.runvia.app/brand/railnow-provided-by-universal.svg"
       alt="Provided by RailNow" height="44">
</a>
```

| 배경 | "Provided by" 로고 | 워드마크 |
|---|---|---|
| 밝은 배경 | [SVG](https://railnow.runvia.app/brand/railnow-provided-by-light.svg) · [PNG](https://railnow.runvia.app/brand/railnow-provided-by-light.png) | [SVG](https://railnow.runvia.app/brand/railnow-logo-light.svg) · [PNG](https://railnow.runvia.app/brand/railnow-logo-light.png) |
| 어두운 배경 | [SVG](https://railnow.runvia.app/brand/railnow-provided-by-dark.svg) · [PNG](https://railnow.runvia.app/brand/railnow-provided-by-dark.png) | [SVG](https://railnow.runvia.app/brand/railnow-logo-dark.svg) · [PNG](https://railnow.runvia.app/brand/railnow-logo-dark.png) |
| 모든 배경 | [SVG](https://railnow.runvia.app/brand/railnow-provided-by-universal.svg) · [PNG](https://railnow.runvia.app/brand/railnow-provided-by-universal.png) | [SVG](https://railnow.runvia.app/brand/railnow-logo-universal.svg) · [PNG](https://railnow.runvia.app/brand/railnow-logo-universal.png) |

정사각형 아이콘: [SVG](https://railnow.runvia.app/brand/railnow-icon.svg) · [PNG 512×512](https://railnow.runvia.app/brand/railnow-icon.png). 로고 주소는 다른 출처에서도 불러올 수 있어 바로 삽입할 수 있습니다.

## OpenAPI 명세

[`openapi/openapi.en.json`](openapi/openapi.en.json)은 영어 OpenAPI 3.0.3 명세입니다. [OpenAPI Generator](https://openapi-generator.tech)로 클라이언트를 만들거나 Postman·Insomnia로 가져올 수 있습니다. 최신 명세는 https://railnow.runvia.app/api/docs/en/json 에 있습니다.

```bash
npx @openapitools/openapi-generator-cli generate \
  -i https://railnow.runvia.app/api/docs/en/json -g typescript-fetch -o ./railnow-client
```

## 데이터 출처와 정확도

RailNow는 서울 열린데이터광장의 실시간 도착정보와 국가철도공단(KRIC)·운영기관의 시각표를 결합합니다. [전체 데이터 출처](https://healthy-sail-1cd.notion.site/3e2ee71053db800f8f4ee381bf6e1aa0?source=copy_link)를 확인하세요.

실시간 갱신 사이의 위치는 추정값입니다. 원본 데이터가 늦거나 빠질 수 있으며 지원 노선만 제공합니다. 안전과 직결된 용도로 사용하지 마세요.

## 문의

- **버그 제보·기능 요청**: [이슈 등록](https://github.com/hongjunna/railnow-api/issues/new/choose)
- **장애·기타 문의**: [junlab0801@gmail.com](mailto:junlab0801@gmail.com)
- **약관**: [API 이용약관 및 개인정보 처리방침](https://healthy-sail-1cd.notion.site/API-3e2ee71053db80d28500db98f8dd0532?source=copy_link)

이 저장소의 예제 코드는 [MIT 라이선스](LICENSE)를 따릅니다. API와 데이터 이용은 위 이용약관을 따릅니다.
