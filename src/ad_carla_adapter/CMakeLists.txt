cmake_minimum_required(VERSION 3.16)
project(ad_carla_adapter)

if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)

# NOTE: carla_msgs 는 별도 워크스페이스(carla_ros_ws)의 오버레이로 들어온다.
#       브릿지를 source 하지 않은 터미널에서도 나머지 패키지가 빌드되어야 하므로
#       QUIET 로 찾고, 없으면 빈 패키지로 조용히 끝낸다.
find_package(carla_msgs QUIET)

if(NOT carla_msgs_FOUND)
    message(STATUS
        "ad_carla_adapter: carla_msgs 를 찾지 못해 건너뛴다. "
        "CARLA 연동이 필요하면 carla_ros_ws 의 setup 을 먼저 source 한다.")
    ament_package()
    return()
endif()

message(STATUS "ad_carla_adapter: carla_msgs 발견 — CARLA 연동 대상으로 빌드한다.")

# TODO: W25 - AckermannDriveStamped 를 CarlaEgoVehicleControl 로 변환하는 노드.
#       종/횡 명령을 throttle/brake/steer 로 사상하는 것이 이 노드의 전부다.
#       제어 수식은 ad_core 에 두고 여기서는 변환과 배선만 한다.
#
# find_package(rclcpp REQUIRED)
# find_package(ackermann_msgs REQUIRED)
#
# add_executable(carla_command_adapter_node src/carla_command_adapter_node.cpp)
# ament_target_dependencies(carla_command_adapter_node rclcpp ackermann_msgs carla_msgs)
# install(TARGETS carla_command_adapter_node DESTINATION lib/${PROJECT_NAME})

install(DIRECTORY include/
    DESTINATION include
)

ament_package()
