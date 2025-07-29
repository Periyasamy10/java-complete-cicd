pipeline {
  agent {
    kubernetes {
      label 'jenkins-slave'
      defaultContainer 'gradle'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:jdk17
  - name: gradle
    image: gradle:8.4-jdk21
    command: ['cat']
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command: [""]
    args: [""]  # <-- Important to override Kaniko default entrypoint
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  volumes:
  - name: kaniko-secret
    secret:
      secretName: regcred  # <-- This must contain Docker config.json
"""
    }
  }

  environment {
    SONAR_TOKEN = credentials('sonar-token')
    DOCKER_CREDS_USR = credentials('docker-hub-creds').username
    DOCKER_CREDS_PSW = credentials('docker-hub-creds').password
  }

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
        git url: 'https://github.com/Periyasamy10/java-complete-cicd.git', branch: 'main'
      }
    }

    stage('Build and Sonar Scan') {
      steps {
        container('gradle') {
          withSonarQubeEnv('SonarQube') {
            sh '''
              chmod +x ./gradlew
              ./gradlew clean build sonarqube \
                -Dsonar.projectKey=java-gradle-app \
                -Dsonar.projectName=Java-app \
                -Dsonar.login=${SONAR_TOKEN}
            '''
          }
        }
      }
    }

    stage('Kaniko Build & Push') {
      steps {
        container('kaniko') {
          script {
            def imageTag = "myapp:${BUILD_NUMBER}"
            sh """
              /kaniko/executor \
                --context=/workspace/java-complete-cicd \
                --dockerfile=/workspace/java-complete-cicd/Dockerfile \
                --destination=docker.io/${DOCKER_CREDS_USR}/${imageTag} \
                --verbosity=debug
            """
          }
        }
      }
    }
  }
}
