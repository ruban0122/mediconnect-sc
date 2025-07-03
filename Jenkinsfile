pipeline {
    agent any

    environment {
        JIRA_SITE = 'sc-section4-g06' // MUST match the Jira site name in Jenkins config
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building project...'
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
