#!/usr/bin/env bash
# src/ 아래 C++ 소스에 .clang-format 을 적용한다.
set -euo pipefail

WS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${WS_ROOT}"

if ! command -v clang-format >/dev/null 2>&1; then
    echo "clang-format 이 없다. 설치: sudo apt install clang-format" >&2
    exit 1
fi

mapfile -t FILES < <(find src -type f \( -name '*.cpp' -o -name '*.hpp' -o -name '*.h' \))

if [ ${#FILES[@]} -eq 0 ]; then
    echo "포맷할 소스가 아직 없다."
    exit 0
fi

clang-format -i "${FILES[@]}"
echo "${#FILES[@]}개 파일 포맷 완료."
