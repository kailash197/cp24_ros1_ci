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

        stage('TEST2: FAILING TESTS') {
            steps {
                script {
                    def failingtestCommand = '''
                        sudo docker-compose exec -T roscore_gazebo bash -c '
                            set -e
                            source /opt/ros/noetic/setup.bash &&
                            source ~/simulation_ws/devel/setup.bash &&
                            rostest tortoisebot_waypoints waypoints_test.test test_pass:=false --reuse-master
                        ' > failingtest_output.txt 2>&1
                    '''

                    def exitCode = sh(script: "${failingtestCommand}", returnStatus: true)

                    echo "===== TEST OUTPUT ====="
                    def testLog = readFile('failingtest_output.txt')
                    echo testLog

                    // Always archive the result
                    archiveArtifacts artifacts: 'failingtest_output.txt', allowEmptyArchive: true

                    // Optional: log a warning
                    if (exitCode != 0) {
                        echo "TEST2 failed with exit code ${exitCode} as expected"
                        echo "Continue the pipeline.."
                    }
                }
            }
        }
    }

    post {
        always {
            echo "==== CLEANUP DOCKER CONTAINER===="
            sh 'sudo docker-compose down'

            echo '==== PIPELINE COMPLETED ===='
            // Optional: Send test results via email or other notification
        }
    }
}
