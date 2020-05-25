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
            steps{
                sh 'export DOCKER_IMAGE_TAG="${PROJECT_MAIN_VERSION}.${PROJECT_SUB_VERSION}.${CIRCLE_BUILD_NUM}"'
                sh '$docker build -t $DOCKER_USER/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG .'
            }
        }
        stage('Upload to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-account', passwordVariable: 'pass', usernameVariable: 'user')]) {
                	sh 'export DOCKER_IMAGE_TAG="${PROJECT_MAIN_VERSION}.${PROJECT_SUB_VERSION}.${CIRCLE_BUILD_NUM}"'
                    sh 'echo $DOCKER_PASS | $docker login -u $DOCKER_USER --password-stdin'
                    sh '$docker push $user/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'
                }

            }
        }
    }
}
