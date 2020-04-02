 #!/bin/bash

CURRENT_DIR="${pwd}"
export PATH=$PATH:/usr/local/openjdk-8/bin

curl -L https://github.com/scalacenter/bloop/releases/download/v1.4.0-RC1/install.py > ~/bloop_install.py
python ~/bloop_install.py --dest $GITPOD_REPO_ROOT/.metals/bloop_local
curl -L https://piccolo.link/sbt-1.3.9.tgz > ~/sbt.tar.gz
mkdir -p $GITPOD_REPO_ROOT/.metals/sbt
tar -C ~ -xvf ~/sbt.tar.gz -C $GITPOD_REPO_ROOT/.metals

echo "-Dsbt.coursier.home=$GITPOD_REPO_ROOT/.metals/coursier" >> .jvmopts
echo "-Dcoursier.cache=$GITPOD_REPO_ROOT/.metals/coursier" >> .jvmopts
echo "-sbt-dir $GITPOD_REPO_ROOT/.metals/sbt" >> .sbtopts
echo "-sbt-boot $GITPOD_REPO_ROOT/.metals/sbt/boot" >> .sbtopts
echo "-ivy $GITPOD_REPO_ROOT/.metals/.ivy2" >> .sbtopts

# TODO should use the Metals  
METALS_VERSION=0.8.3
curl -Lo $GITPOD_REPO_ROOT/.metals/cs https://git.io/coursier-cli-linux && chmod +x $GITPOD_REPO_ROOT/.metals/cs
$GITPOD_REPO_ROOT/.metals/cs fetch org.scalameta:metals_2.12:$METALS_VERSION --cache=$GITPOD_REPO_ROOT/.metals/coursier 
$GITPOD_REPO_ROOT/.metals/cs fetch org.scalameta:scalafmt-cli_2.12:2.4.2 --cache=$GITPOD_REPO_ROOT/.metals/coursier 

source $GITPOD_REPO_ROOT/.metals/bloop_local/bash/bloop
alias sbt=$GITPOD_REPO_ROOT/.metals/sbt/bin/sbt
alias bloop=$GITPOD_REPO_ROOT/.metals/bloop_local/bloop
bloop server &>/dev/null &
sbt -Dbloop.export-jar-classifiers=sources bloopInstall
bloop compile --cascade root