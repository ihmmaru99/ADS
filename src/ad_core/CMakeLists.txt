cmake_minimum_required(VERSION 3.16)
project(ad_core)

if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)

# WARNING: 이 패키지는 rclcpp 를 find_package 하지 않는다.
# ROS 의존이 들어오는 순간 단위 테스트가 시뮬레이터를 요구하게 되고,
# 양산 ECU 이식성과 배포판 이관 내성을 동시에 잃는다.

# TODO: 라이브러리 타깃은 구현이 들어오는 주차에 활성화한다.
#   8주차  - pid_speed_controller / i_longitudinal_controller
#   10주차 - i_lateral_controller / pure_pursuit / stanley
#   12주차 - controller_factory
#   13주차 - bicycle_model (수치해법 5장 ODE 적분과 함께)
#
# add_library(${PROJECT_NAME}
#     src/geometry.cpp
#     src/trajectory.cpp
#     src/path_generator.cpp
#     src/bicycle_model.cpp
#     src/pid_speed_controller.cpp
#     src/pure_pursuit_controller.cpp
#     src/stanley_controller.cpp
#     src/controller_factory.cpp
# )
# target_include_directories(${PROJECT_NAME} PUBLIC
#     $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
#     $<INSTALL_INTERFACE:include>
# )
# install(TARGETS ${PROJECT_NAME}
#     EXPORT export_${PROJECT_NAME}
#     ARCHIVE DESTINATION lib
#     LIBRARY DESTINATION lib
#     RUNTIME DESTINATION bin
# )
# ament_export_targets(export_${PROJECT_NAME} HAS_LIBRARY_TARGET)

install(DIRECTORY include/
    DESTINATION include
)

ament_export_include_directories(include)

if(BUILD_TESTING)
    find_package(ament_cmake_gtest REQUIRED)

    # TODO: 테스트는 구현과 같은 주차에 함께 추가한다. 나중으로 미루지 않는다.
    #
    # ament_add_gtest(test_geometry test/test_geometry.cpp)
    # target_link_libraries(test_geometry ${PROJECT_NAME})
endif()

ament_package()
