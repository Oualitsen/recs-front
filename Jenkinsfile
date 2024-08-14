pipeline {
    agent any
    environment {
        PATH = "$PATH:/opt/3.16.3/bin"
        DEST_FOLDER = '/var/www/html/recs.retailapps.pro'
        URL_BASE = 'https://recs.retailapps.pro/'
        WS_URL_BASE = 'wss://recs.retailapps.pro/'
    }
    stages {
        stage('cloning recs fron') {
            steps {
                echo 'cloning recs admin frontend'
                git branch: 'main', credentialsId: 'ssh-key-github-access', url: 'git@github.com:Oualitsen/recs-front.git'
            }
        }

        stage('init') {
            steps {
                sh 'flutter --version'
                sh 'flutter clean'
            }
        }
        stage('build') {
            steps {
                sh 'flutter pub get'
                sh 'flutter pub run build_runner build -d'
                sh 'flutter pub run build_runner build -d'
                echo 'flutter build web'
                sh "flutter build web --dart-define=URL_BASE=$URL_BASE --dart-define=WS_URL_BASE=$WS_URL_BASE"
            }
        }
        stage('deploy') {
            steps {
                echo "Deleting current version from $DEST_FOLDER"
                sh "rm -rf $DEST_FOLDER/*"
                echo "Copying build/web/* to $DEST_FOLDER"
                sh "cp -rv build/web/* $DEST_FOLDER"
            }
        }
    }
}
