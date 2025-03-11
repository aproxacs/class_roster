# Class Roster (출석부)

Flutter로 개발된 학생 출석 관리 애플리케이션입니다.

## 주요 기능

- 학생 그룹 관리

  - 그룹 생성, 수정, 삭제
  - CSV 파일을 통한 학생 목록 가져오기/내보내기
  - 학생 추가, 수정, 삭제

- 출석부 관리
  - 그룹별 출석부 생성
  - 실시간 출석 체크
  - 출석부 종료 및 CSV 파일로 내보내기
  - 출석 이력 관리

## 시작하기

1. Flutter 설치

```bash
# Flutter SDK 설치: https://flutter.dev/docs/get-started/install
flutter --version
```

2. 의존성 설치

```bash
flutter pub get
```

3. 앱 실행

```bash
flutter run
```

## 개발 환경

- Flutter: 3.x
- Dart: 3.x
- 데이터베이스: SQLite (sqflite)
- 상태 관리: GetX
