pipeline {

    agent none

    options {
        withAWS(credentials:'aws-static')
    }

    stages {
        stage('Lint Shell') {
	    agent {
		docker { image 'koalaman/shellcheck-alpine:v0.7.0',
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
		docker { image 'hadolint/hadolint'}
	    }
            steps {
                sh 'hadolint --ignore DL3013 Dockerfile'
            }
        
        stage('Lint Markdown') {
	    agent {
		docker { image 'ruby:alpine'}
	    }
            steps {
                sh 'gem install mdl'
                sh '>-
                    find <<parameters.lint-dir>> -not -path "*/\.*" -type f -iname "*.md"
                    -exec mdl \{\} \+'
            }
        }
        stage('Lint JavaScript') {
            steps {
                //sh 'tidy -q -e *.html'
            }
        }
        stage('Upload to DockerHub') {
            steps {
                export DOCKER_IMAGE_TAG="${PROJECT_MAIN_VERSION}.${PROJECT_SUB_VERSION}.${CIRCLE_BUILD_NUM}"
                $docker push $DOCKER_USER/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG

            }
        }
    }
}

