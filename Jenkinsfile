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

        // Parasoft Licenses
        ls_url="${PARASOFT_LS_URL}"
        ls_user="${PARASOFT_LS_USER}"
        ls_pass="${PARASOFT_LS_PASS}"
    }
    stages {
        stage('Build') {
            steps {
                // build the project
                sh  '''

                    # Build the Maven project
                    # mvn clean package
                    
                    # Build with Jtest SA/UT/monitor

                    # Create Folder for monitor
                    mkdir monitor

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
                    -u 0:0 \
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
                    unzip **/target/*/*/monitor.zip -d .
                    ls -la monitor
                    
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