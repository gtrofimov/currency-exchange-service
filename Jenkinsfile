pipeline {
    agent any
    tools {
        maven 'maven'
        jdk 'JDK 17'
    }
    environment {
        // vars
        app_name="exchange"
        app_port=8000
    }
    stages {
        stage('Build') {
            steps {
                // build the project
                sh  '''

                    # Build the Maven project
                    mvn clean package
                
                    '''
                }
            }
        stage('Deploy') {
            steps {
                // deploy the project
                sh  '''
                    
                    # Stop app conatiner if running
                    docker stop ${app_name} || true
                    
                    # Build app container
                    docker build --no-cache -t ${app_name} .
                    
                    # Start app container
                    docker run --rm -d -p ${app_port}:${app_port} --network=demo-net --name ${app_name} ${app_name}
                    
                    # Wait for app conatiner to start
                    sleep 15s
                
                    '''
                }
            }
            
        stage('Test') {
            steps {
                // test the project
                sh  '''

                    # Test the App
                    curl -iv --raw http://localhost:${app_port}/currency-exchange/from/EUR/to/INR

                    # cov-tool
                
                    '''
                }
            }
        stage('Release') {
            steps {
                // Release the project
                sh  '''
                    
                    # Clean up
                    # docker stop ${app_name}
                
                    '''
                }
            }
    }
    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                            [pattern: '.propsfile', type: 'EXCLUDE']])
            }
        }
}