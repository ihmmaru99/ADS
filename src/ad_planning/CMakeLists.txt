cmake_minimum_required(VERSION 3.16)
project(ad_planning)

if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)

# NOTE: 노드 패키지는 변환과 배선만 담당한다. 제어 수식은 ad_core 에 둔다.
#       아래 find_package 와 타깃은 노드 구현이 들어오는 주차에 활성화한다.
#
# find_package(rclcpp REQUIRED)
# find_package(nav_msgs REQUIRED)
# find_package(geometry_msgs REQUIRED)
# find_package(ad_core REQUIRED)
#
# add_executable(ad_planning_node src/${PROJECT_NAME}_node.cpp)
# ament_target_dependencies(ad_planning_node rclcpp nav_msgs geometry_msgs ad_core)
# install(TARGETS ad_planning_node DESTINATION lib/${PROJECT_NAME})

install(DIRECTORY include/
    DESTINATION include
)

ament_package()
