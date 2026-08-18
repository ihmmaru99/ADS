#!/usr/bin/env bash
# ad_stack 워크스페이스를 빌드한다. 리포 루트 어디에서 호출해도 동작한다.
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

# NOTE: --symlink-install 은 YAML 과 런치 파일 수정 시 재빌드를 생략하게 해 준다.
colcon build --symlink-install "$@"

echo
echo "빌드 완료. 다음을 실행한다:"
echo "  source ${WS_ROOT}/install/setup.bash"
