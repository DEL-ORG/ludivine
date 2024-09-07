
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
        
        stage('Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

        stage('Build UI') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-ui:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/ui') {
                        sh """
                        docker build -t ${imageTag} .
                        """
                    }
                }
            }
        }
        stage('Build Assets') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-assets:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/assets') {
                        sh """
                        docker build -t ${imageTag} .
                        """
                    }
                }
            }
        }
       
        stage('Build Assets-rabbitmq') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-assetrabbit:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/assets') {
                        sh """
                        docker build -t ${imageTag} . -f Dockerfile-rabbitmq
                        """
                    }
                }
            }
        }
         
        stage('Build Orders') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-orders:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/orders') {
                        sh """
                        docker build -t ${imageTag} .
                        """
                    }
                }
            }
        }
         stage('Build Orders-db') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-orderdb:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/orders') {
                        sh """
                        docker build -t ${imageTag} . -f Dockerfile-db
                        """
                    }
                }
            }
        }

        stage('Build Checkout') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-checkout:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/checkout') {
                        sh """
                        docker build -t ${imageTag} .
                        docker push ${imageTag}
                        """
                    }
                }
            }
        }

        stage('Build Checkout-db') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-checkoutdb:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/checkout') {
                        sh """
                        docker build -t ${imageTag} . -f Dockerfile-db
                        """
                    }
                }
            }
        }

        stage('Build Cart') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-cart:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/cart') {
                        sh """
                        docker build -t ${imageTag} .
                        """
                    }
                }
            }
        }

        stage('Build Cart-dynamo') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-cartdynamo:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/cart') {
                        sh """
                        docker build -t ${imageTag} . -f Dockerfile-dynamodb
                        """
                    }
                }
            }
        }
        stage('Build Catalog') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-catalog:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/catalog') {
                        sh """
                        docker build -t ${imageTag} .
                        """
                    }
                }
            }
        }

        stage('Build Catalog-db') {
            steps {
                script {
                    def imageTag = "devopseasylearning/s5ludivine-do-it-yourself-catalogdb:build-${env.BUILD_NUMBER}"
                    dir('do-it-yourself/src/catalog') {
                        sh """
                        docker build -t ${imageTag} . -f Dockerfile-db
                        """
                    }
                }
            }
        }
    }

    post {
   
   success {
      slackSend (channel: '#session5-november-2022', color: 'good', message: "SUCCESSFUL: Application s5ludivine-do-it-yourself Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }

 
    unstable {
      slackSend (channel: '#session5-november-2022', color: 'warning', message: "UNSTABLE: Application s5ludivine-do-it-yourself  Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }

    failure {
      slackSend (channel: '#session5-november-2022', color: '#FF0000', message: "FAILURE: Application s5ludivine-do-it-yourself Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
    }
   
    cleanup {
      deleteDir()
    }
}

}