pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the DineFinder project...'
                // Add your build commands
            }
        }
    }
}
stage('Update Jira') {
    environment {
        JIRA_SITE = 'sc-section4-g06'  // Must match your Jenkins Jira config name
    }
    steps {
        script {
            def issueKey = 'KAN-2'
            def comment = '✅ Jenkins pipeline ran successfully for mediconnect-sc and updated Jira.'
            jiraAddComment idOrKey: issueKey, comment: comment
        }
    }
}

