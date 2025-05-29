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
                echo 'Waiting for Gazebo to spin up...'
                sleep time: 10, unit: 'SECONDS'
            }
        }

        stage('TEST1: PASSING TESTS') {
            steps {
                script {
                    def testCommand = '''
                        sudo docker-compose exec -T roscore_gazebo bash -c '
                            set -e
                            source /opt/ros/noetic/setup.bash &&
                            source ~/simulation_ws/devel/setup.bash &&
                            rostest tortoisebot_waypoints waypoints_test.test --reuse-master
                        '
                    '''

                    // Run the command and capture both stdout and stderr
                    def testOutput = sh(script: "${testCommand}", returnStdout: true)

                    echo "===== TEST OUTPUT ====="
                    echo testOutput

                    writeFile file: 'passingtest_output.txt', text: testOutput
                    archiveArtifacts artifacts: 'passingtest_output.txt'
                }
            }
            post {
                always {
                    sh '''
                        if [ ! -s passingtest_output.txt ]; then
                            echo "⚠️ Warning: passingtest_output.txt is empty."
                        fi
                    '''
                }
            }
        }

        stage('CLEANUP DOCKER CONTAINER') {
            steps {
                sh 'sudo docker-compose down'
            }
        }
    }
    post {
        always {
            echo 'Pipeline completed'
            // Optional: Send test results via email or other notification
        }
    }
}
