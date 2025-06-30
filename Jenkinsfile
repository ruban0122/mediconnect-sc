pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ruban2201/mediconnect'
        DOCKER_TAG = 'latest'
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/ruban0122/mediconnect-sc.git', branch: 'Mediconnect-Sprint-4'
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
                    echo "Preparing APK..."
        
                    if exist build\\app\\outputs\\flutter-apk\\app-release.apk (
                        echo "Found APK at flutter-apk path"
                        mkdir ci_output
                        copy /Y build\\app\\outputs\\flutter-apk\\app-release.apk ci_output\\
                    ) else if exist build\\app\\outputs\\apk\\release\\app-release.apk (
                        echo "Found APK at alternate apk/release path"
                        mkdir ci_output
                        copy /Y build\\app\\outputs\\apk\\release\\app-release.apk ci_output\\
                    ) else (
                        echo "❌ APK not found in expected locations!"
                        dir build\\app\\outputs
                        exit /b 1
                    )
                '''
            }
}


        stage('Build Docker Image') {
            steps {
                bat '''
                    echo "Current directory contents:"
                    dir
                    docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                bat '''
                    docker push $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }

        stage('Update Jira Issue') {
            steps {
                script {
                    def issueKey = 'KAN-7'
                    
                    // Add a comment to the issue
                    jiraAddComment (
                        idOrKey: issueKey,
                        comment: "✅ Jenkins build #${env.BUILD_NUMBER} successful. Docker image pushed.",
                        site: 'MyJiraSite'
                    )
        
                    // Optionally, you can use REST or curl to transition status (manual setup)
                }
            }
        }

    }

    post {
        success {
            echo '✅ Build and Docker push successful!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
