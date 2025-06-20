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
                git url: 'https://github.com/ruban0122/mediconnect.git', branch: 'Mediconnect-Sprint-4'
            }
        }

        stage('Build APK') {
            steps {
                sh '''
                    echo "Building Flutter APK..."
                    flutter pub get
                    flutter build apk --release
                '''
            }
        }

        stage('Prepare APK') {
            steps {
                sh '''
                    mkdir -p ci_output
                    cp build/app/outputs/flutter-apk/app-release.apk ci_output/
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    docker push $DOCKER_IMAGE:$DOCKER_TAG
                '''
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
