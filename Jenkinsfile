pipeline {
    agent any
    tools {
        maven 'maven'
        jdk 'JDK 17'
    }
    environment {
        // vars
        app_name="currency_exchange_service"
        app_port=8001
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
                    docker build -t ${app_name} .
                    
                    # Start app container
                    docker run --rm -d -p ${app_port}:8000 --name ${app_name} ${app_name}
                    
                    # Wait for app conatiner to start
                    sleep 10s
                
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
                    docker stop ${app_name}
                
                    '''
                }
            }
    }
}