def build(target, nodeLabel='osx', configuration='Release', swift_version='3.0') {
  return {
    node(nodeLabel) {
      def stageName = "${target} ${configuration.toLowerCase()} swift-${swift_version}"
      stage(stageName) {
        // SCM
        sh 'rm -rf *'
        checkout([
          $class: 'GitSCM',
          branches: [[name: "origin/pull/${GITHUB_PR_NUMBER}/head"]],
          doGenerateSubmoduleConfigurations: false,
          extensions: [],
          gitTool: 'native git',
          submoduleCfg: [],
          userRemoteConfigs: [[
            credentialsId: '1642fb1a-1a82-4b10-a25e-f9e95f43c93f',
            name: 'origin',
            refspec: "+refs/heads/master:refs/remotes/origin/master +refs/pull/${GITHUB_PR_NUMBER}/head:refs/remotes/origin/pull/${GITHUB_PR_NUMBER}/head",
            url: 'https://github.com/realm/realm-cocoa.git'
          ]]
        ])
        sh "git submodule update --init --recursive"
        // FIXME: replace ghprbSourceBranch with sha after updating build.sh ci-pr
        sh "target=${target} swift_version=${swift_version} ghprbSourceBranch=${GITHUB_PR_SOURCE_BRANCH} ./build.sh ci-pr"
      }
    }
  }
}

try {
  node {
    step([
      $class: 'GitHubSetCommitStatusBuilder',
      statusMessage: [content: 'Jenkins CI job in progress']]
    )
  }

  // Touchstones
  parallel([
    swiftlint: build('swiftlint'),
    docs: build('docs'),
    osx_swift: build('osx-swift'),
  ])

  node {
    step([
      $class: 'GitHubSetCommitStatusBuilder',
      statusMessage: [content: 'Jenkins CI job in progress (touchstones passed)']]
    )
  }

  parallel([
    // OS X
    osx_release: build('osx', 'osx', 'Release'),
    osx_debug: build('osx', 'osx', 'Debug'),
    osx_encryption: build('osx-encryption'),
  ])

  // Mark build as successful if we get this far
  node {
    currentBuild.rawBuild.setResult(Result.SUCCESS)
  }
} finally {
  node {
    step([
      $class: 'GitHubPRBuildStatusPublisher',
      statusMsg: [content: 'Jenkins CI job finished'],
      unstableAs: 'FAILURE'
    ])
  }
}
