pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ruban2201/mediconnect'
        DOCKER_TAG = "${env.BUILD_NUMBER}"  // Using build number for unique tagging
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/ruban0122/mediconnect-sc.git', 
                     branch: 'Mediconnect-Sprint-4',
                    
            }
        }

        stage('Build APK') {
            steps {
                bat '''
                    echo "Building Flutter APK..."
                    flutter pub get
                    flutter build apk --release
                '''
            }
        }

        stage('Prepare APK') {
            steps {
                bat '''
                    mkdir ci_output || echo "Directory already exists"
                    xcopy /Y "build\\app\\outputs\\flutter-apk\\app-release.apk" "ci_output\\"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                    echo "Current directory contents:"
                    dir
                    docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat '''
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                bat '''
                    docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                '''
            }
        }

        stage('Update Jira Issue') {
            steps {
                script {
                    def issueKey = 'KAN-7'
                    jiraAddComment(
                        idOrKey: issueKey,
                        comment: "✅ Jenkins build #${env.BUILD_NUMBER} successful. Image: %DOCKER_IMAGE%:%DOCKER_TAG%",
                        site: 'MyJiraSite'
                    )
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and Docker push successful!'
            slackSend channel: '#build-notifications',
                      color: 'good',
                      message: "Mediconnect build #${env.BUILD_NUMBER} succeeded! \nImage: ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}"
        }
        failure {
            echo '❌ Build failed!'
            slackSend channel: '#build-notifications',
                      color: 'danger',
                      message: "Mediconnect build #${env.BUILD_NUMBER} failed! \nCheck Jenkins: ${env.BUILD_URL}"
        }
    }
}
