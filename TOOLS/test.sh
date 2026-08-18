#!/usr/bin/env bash
# 단위 테스트를 돌리고 결과를 자세히 출력한다.
set -euo pipefail

WS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${WS_ROOT}"

# WARNING: conda 환경이 활성화되어 있으면 colcon 이 conda 의 python 을 집어
#          catkin_pkg 를 찾지 못하고 빌드가 통째로 실패한다.
#          빌드하는 동안만 conda 경로를 PATH 에서 걷어낸다.
if [[ "${PATH}" == *conda* ]]; then
    PATH="$(printf '%s' "${PATH}" | tr ':' '\n' | grep -v -E 'conda' | paste -sd: -)"
    export PATH
fi
unset PYTHONHOME

# NOTE: ROS2 setup.bash 는 미정의 변수를 참조한다. 이 구간에서만 -u 를 끈다.
set +u
# shellcheck disable=SC1091
source /opt/ros/humble/setup.bash
set -u

PACKAGES=("$@")
if [ ${#PACKAGES[@]} -eq 0 ]; then
    PACKAGES=(ad_core)
fi

colcon test --packages-select "${PACKAGES[@]}" --event-handlers console_direct+
colcon test-result --verbose
