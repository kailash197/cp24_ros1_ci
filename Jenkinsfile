pipeline {
    agent any
    stages {
        stage('BUILD DOCKER CONTAINER') {
            steps {
                sh '''
                    cd ~/simulation_ws/src/ros1_ci
                    sudo docker-compose build
                '''
            }
        }
        stage('START DOCKER CONTAINER') {
            steps {
                sh 'sudo docker-compose up -d'
            }
        }
        
        stage('CHECK DOCKER CONTAINER') {
            steps {
                sh 'sudo docker-compose ps'
            }
        }

        stage('TEST ROS WAYPOINTS INSIDE DOCKER CONTAINER') {
            steps {
                sh '''
                    sudo docker-compose exec -T roscore_gazebo bash -c \
                        "
                            source /opt/ros/noetic/setup.bash \\
                            source ~/simulation_ws/devel/setup.bash \\
                            rostest tortoisebot_waypoints waypoints_test.test --reuse-master \\
                        "
                    '''
                // sh 'sudo docker-compose exec roscore_gazebo -c \
                //     "source /opt/ros/noetic/setup.bash \
                //     cd ~/simulation_ws && catkin_make --pkg tortoisebot_waypoints && source devel/setup.bash \
                //     rostest tortoisebot_waypoints waypoints_test.test --reuse-master"'
                sleep 15
            }
        }

        stage('CLEANUP DOCKER CONTAINER') {
            steps {
                sh 'sudo docker-compose down'
            }
        }

        stage('Done') {
            steps {
                sleep 3
                echo 'Pipeline completed'
            }
        }
    }
}
  