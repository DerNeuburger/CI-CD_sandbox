pipeline {

    agent none

    stages {
        stage('Lint Shell') {
            agent {
                docker {
                    image 'koalaman/shellcheck-alpine:v0.7.0'
                    reuseNode true
                }
            }
            steps {
                //sh 'tidy -q -e *.html'
                sh 'find . -not -path "" \
                -type f -name  "*.sh" | \
                xargs shellcheck --external-sources
            }
        }
        stage('Lint Dockerfile') {
            agent {
                docker {
                    image 'hadolint/hadolint'
                }
            }
            steps {
                sh 'hadolint --ignore DL3013 Dockerfile'
            }
        }
        stage('Lint Markdown') {
            agent {
            	  docker {
                    image 'ruby:alpine'
                }
            }
            steps {
                sh 'gem install mdl'
                sh 'mdl README.md'
            }
        }
        stage('Build Docker Image'){
            agent any
            steps{
                sh "docker build -t derneuburgerdocker/static-webpage:1 ."
            }
        }
        stage('Upload to DockerHub') {
            agent any
            steps {
                withDockerRegistry([credentialsId: 'dockerhub', url: "" ]) {
                    sh 'docker push derneuburgerdocker/static-webpage:1'
                }

            }
        }
    }
}
