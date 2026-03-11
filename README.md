# Landlord Management App

시니어 임대인을 위한 Flutter 기반 임대 관리 앱입니다.

This is a Flutter landlord management app designed for older landlords who need a simple way to track lease expiration dates and follow-up reminders.

## 프로젝트 개요

많은 소규모 임대인은 계약 만료일, 재계약 협의 일정, 연락 필요 항목을 종이나 메모 앱에 따로 관리합니다.  
이 방식은 다음과 같은 문제가 있습니다.

- 오늘 바로 연락해야 할 호실을 놓치기 쉽습니다.
- 계약 만료일이 가까운 호실을 한눈에 보기 어렵습니다.
- 고령 사용자에게 복잡한 앱 구조는 진입 장벽이 큽니다.

이 프로젝트는 이런 문제를 줄이기 위해 만들었습니다.

- 큰 글자
- 단순한 화면 구조
- 오늘 해야 할 일 중심 대시보드
- 계약 만료 및 후속 연락 알림

## 문제 정의

핵심 문제는 기능 부족보다 "무엇을 지금 해야 하는지 바로 보이지 않는 것"입니다.

이 앱은 다음 두 가지에 집중합니다.

1. 계약 만료 관리
2. 후속 연락 일정 관리

## 대상 사용자

- 스마트폰 사용에 익숙하지 않은 고령 임대인
- 여러 호실의 계약 종료일과 연락 일정을 직접 관리하는 개인 임대인
- 빠르게 확인하고 바로 행동할 수 있는 단순한 관리 도구가 필요한 사용자

## 주요 기능

### 1. 계약 CRUD

- 호실 계약 추가
- 계약 정보 수정
- 계약 삭제
- 상세 화면에서 상태 변경

### 2. 로컬 저장

- `shared_preferences` 기반 로컬 persistence
- 앱을 다시 실행해도 계약 목록 유지

### 3. 대시보드 요약

- 오늘 연락할 항목
- 협의중
- 이번 달 만료
- 만료 임박 TOP 3

요약 카드는 탭 가능한 구조로 되어 있어 관련 목록으로 바로 이동할 수 있습니다.

### 4. 다음 연락일 관리

- 다음 연락일 정하기
- 다음 연락일 수정
- 다음 연락일 삭제
- 홈 화면의 오늘 연락 목록과 연결

### 5. 연락 액션

- 전화하기
- 문자/공유

### 6. 로컬 알림

- 후속 연락일 알림
  - `nextContactDate` 당일 오전 9시
- 계약 만료 알림
  - 만료 7일 전 오전 9시
  - 만료 당일 오전 9시

## 현재 구현 상태

현재 앱은 로컬 단일 사용자용 MVP 단계입니다.

구현 완료:

- lease CRUD
- local persistence
- senior-friendly dashboard summaries
- follow-up date management
- follow-up local notifications
- lease expiration local notifications
- phone/share actions
- senior-friendly detail screen layout

아직 미구현:

- cloud sync
- multi-device data sync
- authentication
- backend / Firebase integration
- advanced search and reporting

## 기술 스택

- Flutter
- Dart
- `shared_preferences`
- `flutter_local_notifications`
- `timezone`
- `flutter_timezone`
- `url_launcher`
- `share_plus`

## 프로젝트 구조

```text
lib/
  data_sources/
    unit_lease_local_data_source.dart
    shared_prefs_unit_lease_local_data_source.dart
  models/
    unit_lease.dart
  repositories/
    unit_lease_repository.dart
    in_memory_unit_lease_repository.dart
  screens/
    home_screen.dart
    units_list_screen.dart
    unit_detail_screen.dart
    add_unit_screen.dart
    edit_unit_screen.dart
  services/
    notification_service.dart
  utils/
    unit_lease_formatters.dart
  view_models/
    home_dashboard_data.dart
  main.dart
```

구조 설명:

- `models`: 앱 도메인 데이터
- `data_sources`: 로컬 저장소 접근
- `repositories`: 화면과 데이터 저장소 사이의 중간 계층
- `screens`: 사용자 UI
- `services`: 로컬 알림 등 외부 기능 연동
- `utils`: 공통 포맷팅 헬퍼
- `view_models`: 화면용 파생 데이터 계산

이 구조는 이후 로컬 저장소를 클라우드 저장소로 교체할 때 UI 변경 범위를 줄이는 방향으로 정리되어 있습니다.

## UX 방향

이 앱은 일반적인 관리 도구보다 "시니어 친화성"을 더 우선합니다.

주요 원칙:

- Korean-first UI
- large text
- one primary action per row
- summary-first dashboard
- action-first detail screen
- simple wording for older users

## 향후 로드맵

### 단기

- 알림 탭 시 해당 호실 상세 화면으로 이동
- 오늘 연락 목록과 협의중 목록 UX 개선
- 테스트/운영 데이터 초기화 도구 보강

### 중기

- 검색 및 필터 강화
- 계약 상태별 정렬/보기
- 백업/복원 기능

### 장기

- Firebase 또는 다른 백엔드 도입
- 클라우드 동기화
- 여러 기기 간 데이터 공유
- 사용자 인증

## 포트폴리오 포인트

이 프로젝트는 단순 CRUD 앱이 아니라,

- 실제 사용자 문제를 정의하고
- 고령 사용자 중심으로 UX를 조정하고
- 로컬 저장과 알림 기능을 통합하고
- 이후 클라우드 전환을 고려한 구조로 리팩터링한

모바일 제품 설계/구현 사례로 볼 수 있습니다.

## 실행 방법

```bash
flutter pub get
flutter run
```

## 저장소

- GitHub: <https://github.com/meeso0219/landlord-management-app>
