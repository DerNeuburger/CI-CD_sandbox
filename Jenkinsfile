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
                xargs shellcheck --external-sources | \
                tee -a shellcheck.log'
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
                sh 'find -type f -iname "*.md" -exec mdl {} +'
            }
        }
        stage('Build Docker Image'){
            agent {
            	  docker {
                    image 'docker:stable-dind'
                }
            }
            steps{
                sh 'docker build -t derneuburgerdocker/satic-webpage:1.0 .'
            }
        }
        stage('Upload to DockerHub') {
            agent {
            	  docker {
                    image 'ruby:alpine'
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-account', passwordVariable: 'pass', usernameVariable: 'user')]) {
                    sh 'echo ${pass} | docker login -u ${user} --password-stdin'
                    sh 'docker push derneuburgerdocker/static-webpage:${currentBuild.number}'
                }

            }
        }
    }
}
