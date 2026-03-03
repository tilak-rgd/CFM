import com.cwctravel.hudson.plugins.extended_choice_parameter.ExtendedChoiceParameterDefinition

def checkBox (String name, String values, String defaultValue, int visibleItemCnt=0, String description='', String delimiter=',') {

    // default same as number of values
    visibleItemCnt = visibleItemCnt ?: values.split(',').size()
    return new ExtendedChoiceParameterDefinition(
            name, //name,
            "PT_CHECKBOX", //type
            values, //value
            "", //projectName
            "", //propertyFile
            "", //groovyScript
            "", //groovyScriptFile
            "", //bindings
            "", //groovyClasspath
            "", //propertyKey
            defaultValue, //defaultValue
            "", //defaultPropertyFile
            "", //defaultGroovyScript
            "", //defaultGroovyScriptFile
            "", //defaultBindings
            "", //defaultGroovyClasspath
            "", //defaultPropertyKey
            "", //descriptionPropertyValue
            "", //descriptionPropertyFile
            "", //descriptionGroovyScript
            "", //descriptionGroovyScriptFile
            "", //descriptionBindings
            "", //descriptionGroovyClasspath
            "", //descriptionPropertyKey
            "", //javascriptFile
            "", //javascript
            false, //saveJSONParameterToFile
            false, //quoteValue
            visibleItemCnt, //visibleItemCount
            description, //description
            delimiter //multiSelectDelimiter
            )
}

def testParam = checkBox("Instances", // name
                "Mule-QA", // values
                "Mule-QA", //default value
                0, //visible item cnt
                "Select instances from above, which you want to deploy", // description
                )

properties(
  [parameters([testParam])]
)

def instancesStr = params.Instances;
def instancesList = instancesStr.tokenize(',')
def stagesMap = instancesList.collectEntries {
    ["${it}" : generateStage(it)]
}

def generateStage(job) {
    return {
        stage("BE Deploy to ${job}") {
            timeout(time: 10000, unit: 'SECONDS') { // change to a convenient timeout for you
				input(id: "${job}", message: "Deploy to ${job}?", ok: 'Yes, Deploy', submitter: 'sampath_c,saikumar,ratna,sriteja,srinivas,Sreeramchandra,Ramesh Gudepu,shivarajkumar,sreekanth', submitterParameter: 'Deploy')
			}
            script {
				dir('MuleServer'){
					sshPublisher(continueOnError: false, failOnError: true,
					publishers: [
						sshPublisherDesc(configName: "${job}", verbose: true,
						transfers: [
							sshTransfer(
								cleanRemote: false,
								excludes: '',
								execCommand: '',
								execTimeout: 180000,
								flatten: false,
								makeEmptyDirs: false,
								noDefaultExcludes: false,
								patternSeparator: '[, ]+',
								remoteDirectory: '',
								remoteDirectorySDF: false,
								removePrefix: 'target',
								sourceFiles: 'target/CFMule.war'
							),
							sshTransfer(
								cleanRemote: false,
								excludes: '',
								execCommand: '''installPath=/opt
									dos2unix ${installPath}/*.sh
									chmod 755 ${installPath}/*.sh
									cd ${installPath}
									bash ./server-install.sh''',
								execTimeout: 180000,
								flatten: false,
								makeEmptyDirs: false,
								noDefaultExcludes: false,
								patternSeparator: '[, ]+',
								remoteDirectory: '',
								remoteDirectorySDF: false,
								removePrefix: '',
								sourceFiles: 'server-install.sh'
							)
						])
				   ])
				}
            }
        }
    }
}

pipeline {
    agent {
        node {
            label 'codebuilder'
        }
    }
	
	parameters{
		booleanParam(defaultValue: true, description: 'This will Build BE', name: 'BuildBE')
        booleanParam(defaultValue: false, description: 'This will trigger NightlyBuilds', name: 'NightlyBuilds')
    }

    environment {
        BRANCH_NAME_STRING = sh(script: 'echo ${GIT_BRANCH} | sed "s/\\//-/g"', returnStdout: true).trim().toLowerCase()
        GIT_SHORT_HASH = GIT_COMMIT.take(7)
        TIMESTAMP=sh(script:'date +%s', returnStdout: true).trim()
    }

    stages {
        stage('BuildBE') {
			when {
                expression { return params.BuildBE }
            }
            steps{
                script {
                    dir('MuleServer'){
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }
		stage('Deployement') {
			steps {
                script {
                    parallel stagesMap
                }
            }
		}
		stage('Nightly Builds') {
			when {
                expression { return params.NightlyBuilds }
            }
            steps{
                script {
					dir('MuleServer'){
						sh 'mvn clean package -DskipTests'
						sh 'mvn test -Dmaven.test.failure.ignore=true'
						jacoco()
						withSonarQubeEnv('Sonar') {
							sh 'mvn sonar:sonar -Dsonar.buildbreaker.skip=true'
						}
                        sh 'wget https://nightly-builds.s3.us-west-2.amazonaws.com/config/nightly-build.sh'
                        sh 'sh -x nightly-build.sh'
					}
                }
            }
        }
    }
	
	post {
		always {
			script {
				def mailRecipients = 'jayachandra.a@cloudfulcrum.com,ramesh.g@cloudfulcrum.com'
				def result = currentBuild.currentResult
				def jobName = currentBuild.fullDisplayName
				emailext body: '''${SCRIPT, template="groovy-html.template"}''',
				mimeType: 'text/html',
				subject: "Jenkins Build ${result} Job ${jobName}",
				to: "${mailRecipients}",
				replyTo: "${mailRecipients}",
				recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'RequesterRecipientProvider']]
			}
		}
	}
}
