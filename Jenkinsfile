pipeline {
    agent any 
    environment {
        PATH = "$PATH:/opt/3.16.3/bin"
    }
    stages {
        stage('cloning recs fron') { 
            steps {
               echo "cloning recs admin frontend"
                git branch: 'main', credentialsId: 'ssh-key-github-access', url: 'git@github.com:Oualitsen/recs-front.git'
                //
            }
        }

      stage('init'){
          steps{
               sh "flutter --version" 
               sh "flutter clean" 
          }

      }
      stage('build'){
          steps{
               sh "flutter pub get"
               sh "flutter pub run build_runner build -d"
               sh "flutter pub run build_runner build -d"
               sh "flutter build web --dart-define=URL_BASE=https://dev.recs.retailapps.pro/ --dart-define=WS_URL_BASE=wss://dev.recs.retailapps.pro/"
          }
      }


    }
}
