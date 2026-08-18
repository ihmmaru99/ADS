# ad_stack — 시스템 아키텍처

C++17 · ROS 2 Humble · CARLA 0.9.15
학습 허브 아티팩트 `AD Software Plan` §10 설계도를 이 리포 기준으로 옮긴 문서다.

---

## 1. 단 하나의 규칙

> **알고리즘은 `ad_core` 에, ROS 는 노드에.**
> `ad_core` 는 `rclcpp` 를 include 하지 않는다.

이 규칙 하나에서 나머지 모든 설계 결정이 따라 나온다.

| 얻는 것 | 내용 |
|---|---|
| 속도 | 시뮬레이터 · GPU · roscore 없이 단위 테스트가 1초 안에 돈다 |
| 수명 | Humble → Jazzy 이관 시 `ad_core` 는 한 줄도 바뀌지 않는다 |
| 이식성 | 같은 코드를 ROS 가 없는 양산 ECU 로 옮길 수 있다 |

노드 안에 제어 수식을 쓰는 순간 셋을 동시에 잃는다.

---

## 2. 계층 구조

```
┌─ 외부 시스템 계층 ─────────────────────────────────────────┐
│  ad_sim_bicycle (CARLA 대역)      CARLA ── carla_ros_bridge │
└────────────────────────────────────────────────────────────┘
                          ▲  ▼
┌─ ROS2 노드 계층 — 변환과 배선만 담당 ──────────────────────┐
│  ad_planning        ad_control        ad_carla_adapter      │
│  경로 발행          msg ↔ core 변환    Ackermann → CARLA    │
└────────────────────────────────────────────────────────────┘
                          ▲  ▼
┌─ ad_core — 순수 C++17, ROS 무의존 ─────────────────────────┐
│  geometry · trajectory · path_generator · bicycle_model     │
│  ILateralController  ← PurePursuit / Stanley                │
│  ILongitudinalController ← PidSpeed                         │
│  ControllerFactory                                          │
└────────────────────────────────────────────────────────────┘
```

| 패키지 | 역할 | ROS 의존 | CARLA 의존 |
|---|---|---|---|
| `ad_core` | 기하 · 경로 · 횡종 제어기 · 차량 모델 | **없음** | 없음 |
| `ad_control` | `ad_core` 제어기를 토픽에 연결하는 어댑터 노드 | 있음 | 없음 |
| `ad_planning` | 기준 경로를 `nav_msgs/Path` 로 발행 | 있음 | 없음 |
| `ad_sim_bicycle` | CARLA 대역 시뮬레이터 (운동학 자전거 모델) | 있음 | 없음 |
| `ad_carla_adapter` | `AckermannDriveStamped` → `CarlaEgoVehicleControl` | 있음 | **있음** |
| `ad_bringup` | 런치 · 파라미터 · RViz | 실행만 | 없음 |

CARLA 색깔이 묻은 코드는 `ad_carla_adapter` **하나뿐**이다.
브릿지가 없는 환경에서도 나머지 다섯 패키지는 전부 빌드된다.

---

## 3. 토픽 계약

노드 사이의 유일한 접점이다. 이 계약이 고정되어 있으면 양쪽 구현을 독립적으로 갈아끼울 수 있다.

| 토픽 | 타입 | 발행 | 구독 |
|---|---|---|---|
| `/ad/reference_path` | `nav_msgs/Path` | `ad_planning` | `ad_control` |
| `/ad/odometry` | `nav_msgs/Odometry` | `ad_sim_bicycle` 또는 브릿지 | `ad_control` |
| `/ad/control_cmd` | `ackermann_msgs/AckermannDriveStamped` | `ad_control` | `ad_sim_bicycle` · `ad_carla_adapter` |

CARLA 로 넘어갈 때 바뀌는 것은 `/ad/odometry` 의 발행자와
`/ad/control_cmd` 의 구독자뿐이다. 런치 파일에서 리매핑으로 처리하고 코드는 건드리지 않는다.

| CARLA 측 토픽 | 대응 |
|---|---|
| `/carla/ego_vehicle/odometry` | → `/ad/odometry` |
| `/carla/ego_vehicle/vehicle_control_cmd` | ← `ad_carla_adapter` 출력 |

---

## 4. 검증 피라미드

```
        ┌───────────────────┐
        │  CARLA 폐루프     │  25주차~ · 느리다 · 최소한만
        ├───────────────────┤
        │  통합 (launch)    │  노드 배선 · 토픽 연결 확인
        ├───────────────────┤
        │  ad_sim_bicycle   │  폐루프 수렴 · ROS 필요 · 초 단위
        │  폐루프 테스트    │
        ├───────────────────┤
        │  ad_core 단위     │  ROS 불필요 · 1초 이내 · 여기가 두껍다
        └───────────────────┘
```

바닥이 두꺼워야 위가 의미를 가진다.
`ad_core` 단위 테스트가 통과하지 않으면 CARLA 를 켤 이유가 없다.

---

## 5. 구현 순서

이 설계도의 각 부분이 언제 채워지는지는 학습 허브 아티팩트의 50주 로드맵을 따른다.

| 주차 | 들어오는 것 |
|---|---|
| 8 | `PidSpeedController` · `ILongitudinalController` (제어이론 5장) |
| 10 | `ILateralController` · `PurePursuit` · `Stanley` (차량동역학 4장) |
| 12 | `ControllerFactory` — 12주 뒤 MPC 를 수정 0줄로 받는다 |
| 13 | `BicycleModel` — 수치해법 5장 ODE 적분 (Euler / semi-implicit / RK4 비교) |
| 24 | MPC 추가 — 팩토리의 배당금을 확인하는 주차 |
| 25 | CARLA 연동 · `ad_carla_adapter` 활성화 |
| 29~30 | `ad_perception_core` — 차선 피팅 · SVD 신뢰도 지표 |
| 35~40 | `ad_inference` — 고전 CV 를 AI 로 교체, 출력 계약은 유지 |
| 41~44 | `ad_prediction_core` · `ad_behavior_core` — 안전 필터 |
| 45~48 | `DOCS/SAFETY/` — STPA · HARA · SOTIF · ODD 선언 |

> WARNING: 출력 계약을 먼저 고정하지 않고 AI 모델을 먼저 고르면
> 계획기가 쓸 수 없는 출력이 나와 스택을 다시 짜게 된다. 35주차의 핵심이 이것이다.
