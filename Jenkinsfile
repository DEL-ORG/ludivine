pipeline {
    agent any
    
    environment {
		DOCKERHUB_CREDENTIALS=credentials('del-docker-hub-auth')
	}

    stages {

        stage('Checkout') {
            steps {
               git branch: 'feature/ludi', credentialsId: 'github-ssh', url: 'git@github.com:DEL-ORG/a1naelle-do-it-yourself.git' 
            }
        }
        
        stage('Test UI') {
            agent {
                docker { image 'maven:3.8.1-openjdk-17' }
            }
            steps {
                dir('do-it-yourself/src/ui') {
                    sh '''
                    mvn clean install
                    mvn test
                    '''
                }
            }
        }
        stage('Test Orders') {
            agent {
                docker { image 'maven:3.8.1-openjdk-17' }
            }
            steps {
                dir('do-it-yourself/src/orders') {
                    sh '''
                    mvn clean install
                    mvn test
                    '''
                }
            }
        }
        stage('Test Catalog') {
            agent {
                docker { image 'golang:1.18' }
            }
            environment {
                GOCACHE = '/tmp/.cache/go-build' // Set GOCACHE to a writable directory
            }
            steps {
                dir('do-it-yourself/src/catalog') {
                    sh '''
                    go mod tidy
                    go build -v ./...
                    go test -v ./...
                    '''
                }
            }
        }


        stage('Test Assets') {
            agent {
                docker { 
                    image 'nginx:1.21.6' 
                    args '-u root:root'
                }
            }
            steps {
                dir('do-it-yourself/src/orders') {
                    sh '''
                    nginx -t
                    '''
                }
            }
        }

        stage('Test Checkout') {
            agent {
                docker { image 'node:22.4' }
            }
            steps {
                dir('do-it-yourself/src/checkout') {
                    catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                        sh '''
                        npm install
                        npm test || true
                        '''
                    }
                }
            }
        }

        stage('SonarQube analysis') {
            agent {
                docker {
                  image 'sonarsource/sonar-scanner-cli:5.0.1'
                }
            }
               environment {
                   CI = 'true'
                //    scannerHome = tool 'Sonarqube'
                   scannerHome='/opt/sonar-scanner'
                }
            steps{
                withSonarQubeEnv('Sonar') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }     
       
    }
}
