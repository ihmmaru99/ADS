# ADS — 자율주행 소프트웨어 스택

C++17 · ROS 2 Humble · CARLA 0.9.15 기반 자율주행 스택.
[AD Software Plan](https://claude.ai/code/artifact/531804b3-7b90-4730-8c60-7f0f60eb8342) 50주 로드맵을 따라 한 주에 하나씩 채워 나간다.

---

## 단 하나의 규칙

> **알고리즘은 `ad_core` 에, ROS 는 노드에.** `ad_core` 는 `rclcpp` 를 include 하지 않는다.

시뮬레이터 · GPU · roscore 없이 단위 테스트가 초 단위로 돌고,
배포판을 이관해도 `ad_core` 는 바뀌지 않으며, ROS 가 없는 양산 ECU 로 옮길 수 있다.

---

## 패키지

| 패키지 | 역할 | ROS 의존 | CARLA 의존 | 상태 |
|---|---|---|---|---|
| `ad_core` | 기하 · 경로 · 횡종 제어기 · 차량 모델 (순수 C++17) | **없음** | 없음 | 골격 |
| `ad_control` | `ad_core` 제어기를 토픽에 연결하는 어댑터 노드 | 있음 | 없음 | 골격 |
| `ad_planning` | 기준 경로를 `nav_msgs/Path` 로 발행 | 있음 | 없음 | 골격 |
| `ad_sim_bicycle` | CARLA 대역 시뮬레이터 (운동학 자전거 모델) | 있음 | 없음 | 골격 |
| `ad_carla_adapter` | `AckermannDriveStamped` → `CarlaEgoVehicleControl` | 있음 | **있음** | `COLCON_IGNORE` |
| `ad_bringup` | 런치 · 파라미터 · RViz | 실행만 | 없음 | 골격 |

Phase 5 이후 `ad_perception_core` · `ad_estimation_core` · `ad_prediction_core` ·
`ad_behavior_core` · `ad_inference` · `ad_learning` 이 순차 추가된다.

---

## 빌드

```bash
sudo apt install -y ros-humble-ackermann-msgs python3-colcon-common-extensions

./TOOLS/build.sh
source install/setup.bash
```

`ad_carla_adapter` 는 `COLCON_IGNORE` 가 붙어 있어 빌드에서 제외된다.
CARLA 브릿지를 설치하는 25주차에 이 파일을 지운다.

## 테스트

```bash
./TOOLS/test.sh          # ad_core 단위 테스트
./TOOLS/test.sh ad_core ad_control
```

`ad_core` 테스트는 ROS 없이 돈다. 시뮬레이터를 요구하는 테스트가 있다면 그 테스트는 잘못 놓인 것이다.

## 포맷

```bash
./TOOLS/format.sh        # .clang-format 적용
```

---

## 알아둘 것 — conda 와 colcon

이 머신은 conda(anaconda3)가 활성화된 상태라 `python3` 가 conda 쪽을 가리킨다.
그 python 에는 `catkin_pkg` 가 없어서 `colcon build` 를 직접 부르면 다음으로 실패한다.

```
ModuleNotFoundError: No module named 'catkin_pkg'
```

`TOOLS/build.sh` 와 `TOOLS/test.sh` 는 실행 중에만 PATH 에서 conda 경로를 걷어내므로
이 문제를 겪지 않는다. **colcon 을 직접 부르지 말고 이 스크립트를 쓴다.**
직접 불러야 한다면 먼저 `conda deactivate` 를 한다.

## 구조

```
ADS/                          git root = colcon workspace
├── src/                      ROS2 패키지 (소문자 snake_case — ament 요구사항)
├── DOCS/
│   ├── ARCHITECTURE.md       계층 · 토픽 계약 · 검증 피라미드
│   ├── DECISIONS/            ADR — 설계 결정과 그 이유
│   └── SAFETY/               STPA · HARA · SOTIF · ODD 선언 (Phase 9)
├── TOOLS/                    build.sh · test.sh · format.sh
└── CLAUDE.md                 이 리포의 C++ 코딩 규칙
```

## 브랜치 · 태그

- 주차 작업은 `week/W08-pid-controller` 형태의 브랜치에서 하고 `main` 에 머지한다
- 관문 통과 시 태그를 단다 — `g1-w07` · `g2-w14` · `g3-w24` · `g4-w30` · `g5-w44` · `g6-w50`

## 관련

- 학습 실습 기록: `ihmmaru99/SELF_STUDY` (private)
- 시뮬레이터 환경: 로컬 `CARLA_SIM/`
