# ADR 0002 — CARLA ↔ ROS2 브릿지 선택과 연결 구조

- 상태: 채택
- 일자: 2026-08-21

## 맥락

CARLA 0.9.15(네이티브, `~/carla`)를 ADS 워크스페이스에 연결해야 한다.
공식 `carla-simulator/ros-bridge` 는 ROS2 Foxy(Ubuntu 20.04) 전용이라 Humble 에서 쓸 수 없다.

## 결정

### 1. 포크는 `ttgamage/carla-ros-bridge` 를 쓴다

환경 가이드가 첫 번째로 제시한 `gezp/carla_ros` 는 **쓸 수 없다.**
원격 브랜치를 확인한 결과 `humble-carla-0.9.14` 와 `master` 뿐이고 **0.9.15 브랜치가 없다.**

| 포크 | CARLA | ROS2 | Ubuntu | Python | 판정 |
|---|---|---|---|---|---|
| `gezp/carla_ros` | 0.9.14 | Humble | 22.04 | — | 버전 불일치 |
| `ttgamage/carla-ros-bridge` | **0.9.15** | Humble | 22.04 | 3.10 | 채택 |

우리 구성과 네 항목이 전부 일치한다. CARLA 를 0.9.14 로 내리는 대안보다 이쪽이 싸다.

설치 위치: `~/carla_ros_ws` (ADS 와 분리한 별도 워크스페이스, 19개 패키지)

### 2. `ad_carla_adapter` 는 `carla_msgs` 유무로 자동 분기한다

`COLCON_IGNORE` 로 막아두던 방식을 버리고, CMake 에서 `find_package(carla_msgs QUIET)` 로
찾아 없으면 빈 패키지로 조용히 끝낸다.

```cmake
find_package(carla_msgs QUIET)
if(NOT carla_msgs_FOUND)
    ament_package()
    return()
endif()
```

이렇게 하면 브릿지를 source 하지 않은 터미널에서도 나머지 5개 패키지가 정상 빌드되고,
브릿지를 올린 터미널에서는 어댑터가 자동으로 빌드 대상이 된다. 검증 완료.

### 3. 오버레이는 별칭으로 명시적으로 부른다

`.zshrc` 에 `install/setup` 을 직접 넣지 않는다. 워크스페이스가 셋이 되면 순서가 엉킨다.

```zsh
alias sr='source /opt/ros/humble/setup.zsh'
alias sad='...humble + ADS'
alias sbridge='...humble + carla_ros_ws'
alias sfull='...humble + carla_ros_ws + ADS'
```

> WARNING: zsh 에서는 `setup.bash` 가 아니라 **`setup.zsh`** 를 source 해야 한다.
> `.bash` 를 쓰면 스크립트가 자기 경로를 현재 디렉터리로 잘못 잡아 오버레이가 안 붙는다.
> 실제로 이 함정을 밟아 `carla_msgs_DIR-NOTFOUND` 가 났다.

### 4. role name 은 파라미터로 둔다

브릿지의 ego vehicle role name 이 `ego_vehicle` 이 아니라 **`hero`** 였다.
런치 파라미터로 바뀌는 값이므로 리매핑 대상을 하드코딩하지 않는다.

## 검증 (2026-08-21)

| 항목 | 결과 |
|---|---|
| 브릿지 빌드 | 19개 패키지 통과 |
| ADS 빌드 (브릿지 없이) | 6개 통과, 어댑터는 건너뜀 |
| ADS 빌드 (브릿지 오버레이) | 6개 통과, `carla_msgs 발견` |
| 브릿지 ↔ CARLA | ego vehicle 스폰, carla 토픽 44개 |
| `/carla/hero/odometry` | **10.25 Hz**, 실제 좌표 수신 |

## 남은 일 (W25)

배관만 뚫었다. 실제 제어 왕복은 `ad_core`·`ad_control` 구현이 있어야 가능하다.

1. `carla_command_adapter_node.cpp` — `AckermannDriveStamped` → `CarlaEgoVehicleControl`
2. `ad_bringup/launch/carla.launch.py` — role name 파라미터화, 토픽 리매핑
3. `ad_carla_adapter/CMakeLists.txt` 의 주석 처리된 타깃 블록 활성화
