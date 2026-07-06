pipeline {
    agent any

    stages {
        stage('Read Yaml file') {
            steps {
                script {
                    def yamlData = readYaml file: 'properties.yaml'
                    def multibranchFolder = env.JOB_NAME.split("/")[0]
                    def timestamp = new Date().format("yyyyMMdd_HHmmss")

                    env.BRANCH            = yamlData.config.branch
                    env.MAIL_ID           = yamlData.config.mail_id
                    env.CREDENTIAL_ID     = yamlData.config.credential_id
                    env.JOBNAME_UNIQUE_ID = yamlData.config.jobname_uniqueid
		            env.BUILD_PATH        = "${env.JENKINS_HOME}/jobs/${multibranchFolder}/branches/${env.JOBNAME_UNIQUE_ID}/builds/${env.BUILD_NUMBER}"
					env.DB_URL            = yamlData.config.url
					env.CHANGELOG_FILE    = yamlData.config.changeLogFile
                    env.LOG_FILE_VALIDATE = "validate_${env.JOBNAME_UNIQUE_ID}_${timestamp}.txt"
                    env.LOG_FILE_STATUS   = "status_${env.JOBNAME_UNIQUE_ID}_${timestamp}.txt"
                    env.LOG_FILE_UPDATE   = "update_${env.JOBNAME_UNIQUE_ID}_${timestamp}.txt"
                    env.JDBC_CLASSPATH    = "/var/lib/jenkins/liquibase/mysql-connector-j-9.3.0.jar"
                    env.TAG              = "${env.BRANCH}_${timestamp}"

                    echo "Branch = ${env.BRANCH}"
                    echo "Mail Id = ${MAIL_ID}"
                    echo "Credential Id = ${CREDENTIAL_ID}"
		            echo "Build path = ${BUILD_PATH}"
                    echo "Job name unique id = ${JOBNAME_UNIQUE_ID}"
					echo "DB URL = ${DB_URL}"
					echo "Changelog file = ${CHANGELOG_FILE}"
					echo "Validate log file = ${LOG_FILE_VALIDATE}"
					echo "Status log file = ${LOG_FILE_STATUS}"
					echo "Update log file = ${LOG_FILE_UPDATE}"
                    echo "JDBC Classpath = ${JDBC_CLASSPATH}"
                    echo "Tag = ${TAG}"
                }
            }
        }

		stage('Setup DB Credentials') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${CREDENTIAL_ID}", usernameVariable: 'DB_USER', passwordVariable: 'DB_PASSWORD')]) {
                        env.LIQUIBASE_COMMAND_USERNAME = DB_USER
                        env.LIQUIBASE_COMMAND_PASSWORD = DB_PASSWORD
                    }
                }
            }
        }

		stage('Liquibase Validate') {
            steps {
                echo 'Validating Liquibase changelog...'
                sh """
                    liquibase --classpath=$JDBC_CLASSPATH \
                    --changeLogFile=$CHANGELOG_FILE \
                    --url=$DB_URL \
                    --logFile=$LOG_FILE_VALIDATE \
                    --logLevel=info \
                    validate \
                    --labels='BASE OR AI'
                """
            }
        }

        stage('Liquibase Status') {
            steps {
                echo 'Checking Liquibase status...'
                sh """
                    liquibase --classpath=$JDBC_CLASSPATH \
                    --changeLogFile=$CHANGELOG_FILE \
                    --url=$DB_URL \
                    --logFile=$LOG_FILE_STATUS \
                    --logLevel=info \
                    status \
                    --labels='BASE OR AI'
                """
            }
        }

		stage('Liquibase Update') {
            steps {
                echo 'Running Liquibase update...'
                script {
                    try {
                        sh """
                            liquibase --classpath=$JDBC_CLASSPATH \
                            --changeLogFile=$CHANGELOG_FILE \
                            --url=$DB_URL \
                            --logFile=$LOG_FILE_UPDATE \
                            --logLevel=info \
                            update \
                            --labels='BASE OR AI'
                        """
                        echo "Liquibase update executed successfully."

                        echo 'Tagging database state...'
                        sh """
                            liquibase --classpath=$JDBC_CLASSPATH \
                            --changeLogFile=$CHANGELOG_FILE \
                            --url=$DB_URL \
                            --logFile=$LOG_FILE_STATUS \
                            --logLevel=info \
                            tag $TAG
                        """
                    } catch (err) {
                        echo "Liquibase update failed. Check logs at ${LOG_FILE_UPDATE}"
                        error("Stopping pipeline due to Liquibase failure.")
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                multibranchFolder = env.JOB_NAME.split("/")[0]
                encodedBranchName = java.net.URLEncoder.encode(env.BRANCH_NAME, "UTF-8")
                consoleUrl = "http://192.168.1.253:8080/job/${multibranchFolder}/job/${encodedBranchName}/${env.BUILD_NUMBER}/console"
                buildUrl = "http://192.168.1.253:8080/job/${multibranchFolder}/job/${encodedBranchName}/${env.BUILD_NUMBER}/"
                echo "Build result: ${currentBuild.result}"
            }
            echo 'Archiving artifacts regardless of pipeline result...'
            archiveArtifacts artifacts: "${LOG_FILE_VALIDATE}", followSymlinks: false, allowEmptyArchive: true
            archiveArtifacts artifacts: "${LOG_FILE_STATUS}", followSymlinks: false, allowEmptyArchive: true
            archiveArtifacts artifacts: "${LOG_FILE_UPDATE}", followSymlinks: false, allowEmptyArchive: true
        }
        success {
            emailext attachLog: true,
                body: '<h1 style="color:green;">Build Success</h1>',
                subject: "Mysql Script Execution ${env.BRANCH} Success",
                to: "${env.MAIL_ID}"
            office365ConnectorSend(
                webhookUrl: 'https://polussoftware0.webhook.office.com/webhookb2/4b5bab47-7e0c-4f1a-a301-ab5f41c615f9@74324cf0-bf2f-47cc-bdc3-b8d07890b569/JenkinsCI/a30626b683af4b7bbcc7d4183489f900/96535c2e-42d9-4a97-adec-bf6c28ac4a8f/V2UI5F1Lfm--kvgGUsD5o3orM4ceEgX7HM4P-ihrZj-eM1',
                message: """
                <html>
                    <body>
                        <p><strong>Execution Status:</strong> SUCCESS</p>
                        <p><strong>Branch:</strong> ${env.BRANCH}</p>
                        <p><strong>Console Output:</strong> <a href="${consoleUrl}">View Log</a></p>
                        <p><strong>Build Detail Output:</strong> <a href="${buildUrl}">View Build</a></p>
                    </body>
                </html>
                """
            )
        }
        failure {
                    emailext attachLog: true,
                        body: '<h1 style="color:red;">Build Failed</h1><p>Please check the attached log for more details.</p>', 
                        subject: "Mysql Script Execution ${env.BRANCH} Failure",
                        to: "${env.MAIL_ID}"
                    office365ConnectorSend(
                        webhookUrl: 'https://polussoftware0.webhook.office.com/webhookb2/4b5bab47-7e0c-4f1a-a301-ab5f41c615f9@74324cf0-bf2f-47cc-bdc3-b8d07890b569/JenkinsCI/a30626b683af4b7bbcc7d4183489f900/96535c2e-42d9-4a97-adec-bf6c28ac4a8f/V2UI5F1Lfm--kvgGUsD5o3orM4ceEgX7HM4P-ihrZj-eM1',
                        message: """
                        <html>
                            <body>
                                <p><strong>Execution Status:</strong> FAILURE</p>
                                <p><strong>Branch:</strong> ${env.BRANCH}</p>
                                <p><strong>Console Output:</strong> <a href="${consoleUrl}">View Log</a></p>
                                <p><strong>Build Detail Output:</strong> <a href="${buildUrl}">View Build</a></p>
                            </body>
                        </html>
                        """
                    )
        }
    }
}
