pipeline {
    agent any

    environment {
        JIRA_SITE = 'https://sc-section4-g06.atlassian.net'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Running build...'
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
