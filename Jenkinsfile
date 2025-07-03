pipeline {
    agent any

    environment {
        JIRA_SITE = 'Jira'  // must match the Jira "Name" in Jenkins config
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
                    def comment = '✅ Jenkins pipeline ran successfully and updated Jira.'
                    jiraAddComment idOrKey: issueKey, comment: comment
                }
            }
        }
    }
}
