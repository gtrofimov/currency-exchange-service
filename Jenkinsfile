pipeline {
    agent any
    tools {
        maven 'maven'
        jdk 'JDK 17'
    }
    options {
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
    
    }
    environment {
        // Application Config
        app_name="exchange"
        app_port=8000

        // Parasoft Licenses
        ls_url="${PARASOFT_LS_URL}"
        ls_user="${PARASOFT_LS_USER}"
        ls_pass="${PARASOFT_LS_PASS}"

        // Parasoft Covarge Agent
        cov_port=8051
    }
    stages {
        stage('Build') {
            steps {
                // Clean before build
                cleanWs()
                
                // Checkout project
                checkout scm

                // build the project                
                echo "Building ${env.JOB_NAME}..."
                sh  '''
                    

                    # Build the Maven package
                    # mvn clean package
                    
                    # Build the Maven package with Jtest Coverage Agent

                    # Create Folder for monitor
                    mkdir monitor | true

                    # Set Up and write .properties file
                    echo $"
                    parasoft.eula.accepted=true
                    jtest.license.use_network=true
                    jtest.license.network.edition=server_edition
                    license.network.use.specified.server=true
                    license.network.auth.enabled=true
                    license.network.url=${ls_url}
                    license.network.user=${ls_user}
                    license.network.password=${ls_pass}" >> jtest/jtestcli.properties
                    
                    # Debug: Print jtestcli.properties file
                    cat jtest/jtestcli.properties

                    # Run Maven build with Jtest tasks via Docker
                    docker run --rm -i \
                    -u 995:991 \
                    -v "$PWD:$PWD" \
                    -w "$PWD" \
                    $(docker build -q ./jtest) /bin/bash -c " \
                    mvn \
                    -DskipTests=true \
                    package jtest:monitor \
                    -s /home/parasoft/.m2/settings.xml \
                    -Djtest.settings='/home/parasoft/jtestcli.properties'; \
                    "

                    # Unzip monitor.zip
                    unzip target/*/*/monitor.zip -d .
                    cp monitor/static_coverage.xml monitor/static_coverage_${cov_port}.xml
                    
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
                    docker run --rm -d \
                    -p ${app_port}:${app_port} \
                    -p ${cov_port}:8050 \
                    -v "$PWD/monitor:/monitor" \
                    --env-file "$PWD/jtest/monitor.env" \
                    --network=demo-net \
                    --name ${app_name} ${app_name}
                    
                    # Wait for app conatiner to start
                    sleep 15s
                
                    '''
                }
            }
        stage('Test') {
            steps {

                // run component tests with cov
                // start cov agent session and test
                sh  '''
                    # Test the Agent
                    curl -iv --raw http://localhost:${cov_port}/status
                    
                    # Start the Test
                    curl -iv --raw http://localhost:${cov_port}/test/start/jenkinsTest${BUILD_NUMBER}
                    '''

                // run component tests
                sh  '''    
                    # Test the App
                    curl -iv --raw http://localhost:${app_port}/currency-exchange/from/EUR/to/INR
                    '''
                
                // stop cov agent session and generate report
                sh  '''
                    # Stop the Test
                    curl -iv --raw http://localhost:${cov_port}/session/stop
                
                    # run Jtest to generate report
                    docker run --rm -i \
                    -u 0:0 \
                    -v "$PWD:$PWD" \
                    -v "$PWD/jtest/jtestcli.properties:/home/parasoft/jtestcli.properties" \
                    -w "$PWD" \
                    parasoft/jtest \
                    jtestcli \
                    -settings /home/parasoft/jtestcli.properties \
                    -staticcoverage "monitor/static_coverage.xml" \
                    -runtimecoverage "monitor/runtime_coverage" \
                    -config "jtest/CalculateApplicationCoverage.properties" \
                    -property report.coverage.images="${app_name}-ComponentTests" \
                    -property session.tag="ComponentTests"

                    '''
                // run e2e test job
                // build job: 'currency-e2e-tests', propagate: true, wait: true
                
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
            always {
                archiveArtifacts artifacts: 'monitor/static_coverage_*.xml', onlyIfSuccessful: true
            
            sh  ''' 
                rm -rf ".jtest/cache"                
                rm -rf "*/*/*/.jtest/cache" 
                '''
            }
        }
}