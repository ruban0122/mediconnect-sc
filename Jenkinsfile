pipeline {
    agent any

    environment {
        JIRA_SITE = 'sc-section4-g06'  // Make sure this matches your Jenkins Jira config name
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the DineFinder project...'
                // Add your build commands here
            }
        }

        stage('Update Jira') {
            steps {
                script {
                    def issueKey = 'KAN-2'
                    def comment = '✅ Jenkins pipeline ran successfully for mediconnect-sc and updated Jira.'
                    jiraAddComment idOrKey: issueKey, comment: comment
                }
            }
        }
    }
}
