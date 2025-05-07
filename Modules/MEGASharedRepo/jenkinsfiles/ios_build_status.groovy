@Library(['jenkins-android-shared-lib', 'jenkins-ios-shared-lib']) _

pipeline {
    agent { label 'mac-jenkins-slave-ios' }
    options {
        timeout(time: 45, unit: 'MINUTES') 
        gitLabConnection('GitLabConnection')
        gitlabCommitStatus(name: 'Jenkins')
        ansiColor('xterm')
    }
    environment {
        MEGASHAREDREPO_IOS_PROJECT_ID = credentials('MEGASHAREDREPO_IOS_PROJECT_ID')
        GITLAB_API_BASE_URL = credentials('GITLAB_API_BASE_URL')
    }
    post { 
        failure {
            script {
                statusNotifier.postFailure(":x: Build status failed", env.MEGASHAREDREPO_IOS_PROJECT_ID)
            }
            
            updateGitlabCommitStatus name: 'Jenkins', state: 'failed'
        }
        success {
            script {
                envInjector.injectEnvs {
                    statusNotifier.postSuccess(":white_check_mark: Build status check succeeded", env.MEGASHAREDREPO_IOS_PROJECT_ID)
                }
            }

            updateGitlabCommitStatus name: 'Jenkins', state: 'success'
        }
        aborted {
            script {
                statusNotifier.postFailure(":x: Build aborted", env.MEGASHAREDREPO_IOS_PROJECT_ID)
            }
        }
        cleanup {
            deleteDir() /* clean up our workspace */
        }
    }
    stages {
        stage('submodule update') { 
            steps {
                gitlabCommitStatus(name: 'submodule update') {
                    withCredentials([gitUsernamePassword(credentialsId: 'Gitlab-Access-Token', gitToolName: 'Default')]) {
                        script {
                            envInjector.injectEnvs {
                                sh "git submodule foreach --recursive git clean -xfd"
                                sh "git submodule sync --recursive"
                                sh "git submodule update --init --recursive"
                            }
                        }
                    }
                }
            }
        }
        stage('Checkout SDK') {
            steps {
                gitlabCommitStatus(name: 'Checkout SDK') {
                    withCredentials([gitUsernamePassword(credentialsId: 'Gitlab-Access-Token', gitToolName: 'Default')]) {
                        script {
                            envInjector.injectEnvs {
                                util.useGpg() {
                                    def sdkPath = "../../DataSource/MEGASDK/Sources/MEGASDK"
                                    def projectURL = GITLAB_API_BASE_URL.replace("/api/v4", "/sdk/sdk.git")
                                    def hostAppURL = GITLAB_API_BASE_URL.replace("/api/v4", "/mobile/ios/megapasswordmanager.git")
                                    def checkoutBranch = "develop"
                                    def sdkSPMFilePathInHostApp = "Submodules/DataSource/MEGASDK"

                                    dir("scripts/CheckoutCode") {
                                       sh "swift run CheckoutCode --project-url-string ${projectURL} --checkout-branch ${checkoutBranch} --path ${sdkPath} --host-app-project-url-string ${hostAppURL} --host-app-checkout-branch ${checkoutBranch}  --sdk-spm-file-path-in-host-app ${sdkSPMFilePathInHostApp}"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Run unit tests for MEGAInfrastructure') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAInfrastructure') {
                    script {
                        test("MEGAInfrastructure", "MEGAInfrastructure-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAAccountManagement') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAAccountManagement') {
                    script {
                        test("MEGAAccountManagement", "MEGAAccountManagement-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGASwift') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGASwift') {
                    script {
                        test("MEGASwift", "MEGASwift")
                    }
                }
            }
        }
        stage('Run unit tests for MEGADeeplinkHandling') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGADeeplinkHandling') {
                    script {
                        test("MEGADeeplinkHandling", "MEGADeeplinkHandling")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAPreference') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAPreference') {
                    script {
                        test("MEGAPreference", "MEGAPreference")
                    }
                }
            }
        }
        stage('Run unit tests for MEGASharedRepoL10n') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGASharedRepoL10n') {
                    script {
                        test("MEGASharedRepoL10n", "MEGASharedRepoL10n")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAWhatsNew') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAWhatsNew') {
                    script {
                        test("MEGAWhatsNew", "MEGAWhatsNew-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAAuthentication') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAAuthentication') {
                    script {
                        test("MEGAAuthentication", "MEGAAuthentication-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAAnalytics') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAAnalytics') {
                    script {
                        test("MEGAAnalytics", "MEGAAnalytics-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGACancelSurvey') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGACancelSurvey') {
                    script {
                        test("MEGACancelSurvey", "MEGACancelSurvey-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAConnectivity') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAConnectivity') {
                    script {
                        test("MEGAConnectivity", "MEGAConnectivity-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGADebugLogger') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGADebugLogger') {
                    script {
                        test("MEGADebugLogger", "MEGADebugLogger-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGANotifications') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGANotifications') {
                    script {
                        test("MEGANotifications", "MEGANotifications-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAPresentation') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAPresentation') {
                    script {
                        test("MEGAPresentation", "MEGAPresentation-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGASDKRepo') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGASDKRepo') {
                    script {
                        test("MEGASDKRepo", "MEGASDKRepo-Package")
                    }
                }
            }
        }
        stage('Run unit tests for MEGASettings') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGASettings') {
                    script {
                        test("MEGASettings", "MEGASettings")
                    }
                }
            }
        }
        stage('Run unit tests for MEGAStoreKit') {
            steps {
                gitlabCommitStatus(name: 'Run unit tests for MEGAStoreKit') {
                    script {
                        test("MEGAStoreKit", "MEGAStoreKit-Package")
                    }
                }
            }
        }
        stage('Build MEGATest package') {
            steps {
                gitlabCommitStatus(name: 'Build MEGATest package') {
                    script {
                        test("MEGATest", "MEGATest", true)
                    }
                }
            }
        }
        stage('Build MEGAUIComponent package') {
            steps {
                gitlabCommitStatus(name: 'Build MEGAUIComponent package') {
                    script {
                        test("MEGAUIComponent", "MEGAUIComponent", true)
                    }
                }
            }
        }
    }
}

def test(folder, target, buildOnly = false) {
    def buildType = buildOnly ? "build" : "build test"
    def enableCodeCoverage = buildOnly ? "" : "-enableCodeCoverage YES"
    withCredentials([gitUsernamePassword(credentialsId: 'Gitlab-Access-Token', gitToolName: 'Default')]) {
        envInjector.injectEnvs {
            dir("${folder}/") {
                sh "set -o pipefail && env NSUnbufferedIO=YES xcodebuild -scheme ${target} -derivedDataPath derivedData -clonedSourcePackagesDirPath SwiftPackages -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' ${enableCodeCoverage} -skipPackagePluginValidation ${buildType} | tee '/var/lib/jenkins/Library/Logs/scan/MEGASHAREDREPO-MEGASHAREDREPO.log' | xcbeautify"
            }
        }
    }
}