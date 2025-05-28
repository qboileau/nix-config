#!/usr/bin/env bash

# rebase current branch to another (default develop)
rebase () {

 rebaseBranch=${1:-"develop"}
 currentBranch=`git symbolic-ref --short -q HEAD`
 if [ `git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l` -ne 0 ]; then
   dirty=true
 else
   dirty=false
 fi

 echo "##### Rebase branch ${currentBranch} -> ${rebaseBranch} with dirty:${dirty}"

 if [ "$dirty" = true ]; then
   echo "##### Stash modifications"
   git stash
 fi

 echo  "#### Update current"
 git pull --rebase

 echo  "#### Update ${rebaseBranch}"
 git checkout $rebaseBranch
 git pull --rebase

 echo  "#### Rebase"
 git co $currentBranch
 git rebase -i $rebaseBranch

 read -p "Force push rebase result to origin (y/n)?" -n 1 -r
 echo    # (optional) move to a new line
 if [[ $REPLY =~ ^[Yy]$ ]] ;then
   if [[ "$currentBranch" -eq "develop" || "$currentBranch" -eq "master" ]] ;then
     echo "FORCE PUSH TO MASTER OR DEVELOP BRANCHES NOT ALLOWED"
   else
     git push -f origin $currentBranch
   fi
 fi

 if [ "$dirty" = true ]; then
   echo  "#### Re-apply modifications"
   git stash pop
 fi
}

clean_gone_branches() {
   git branch -vv | grep gone | awk '{print $1}' | xargs git branch -D
}

create_worktree_from_branch() {
  
  test_branch=${1:-"develop"}
  clean_test_branch=`echo $test_branch | sed -r 's/[\/]+/-/g'`

  project_dir=`pwd`
  test_dir="$project_dir-test-$clean_test_branch"

  mkdir $test_dir
  echo "Create worktree for branch $test_branch on directory $test_dir"
  git worktree add --detach $test_dir $test_branch
}

test_in_worktree() {

  test_branch=${1:-"develop"} | sed -r 's/[\/]+/-/g'

  project_dir=`pwd`
  test_dir=$project_dir-test-$test_branch
  mkdir $test_dir
  echo "Create worktree for branch $test_branch on directory $test_dir"
  git worktree add --detach $test_dir $test_branch
  cd $test_dir
  pwd

  echo "Run tests"
  sbt test

  cd $project_dir
  echo "Remove test dir $test_dir"
  rm -rf $test_dir
}

git_squash_main(){
  echo "Commit all files to tmp branch"
  git checkout --orphan tmp
  git add -A
  git commit -m "Initial commit"
  echo "Replace main with tmp"
  git branch -D main
  git branch -m main
  echo "Force push main update and cleanup"
  git push -f origin main
  git gc --aggressive --prune=all
}


# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1 -C $2 ;;
      *.tar.gz)    tar xzf $1 -C $2  ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1  -C $2  ;;
      *.tbz2)      tar xjf $1 -C $2  ;;
      *.tgz)       tar xzf $1 -C $2  ;;
      *.zip)       unzip $1   -d $2  ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


colors() {
  local fgc bgc vals seq0

  printf "Color escapes are %s\n" '\e[${value};...;${value}m'
  printf "Values 30..37 are \e[33mforeground colors\e[m\n"
  printf "Values 40..47 are \e[43mbackground colors\e[m\n"
  printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

  # foreground colors
  for fgc in {30..37}; do
    # background colors
    for bgc in {40..47}; do
      fgc=${fgc#37} # white
      bgc=${bgc#40} # black

      vals="${fgc:+$fgc;}${bgc}"
      vals=${vals%%;}

      seq0="${vals:+\e[${vals}m}"
      printf "  %-9s" "${seq0:-(default)}"
      printf " ${seq0}TEXT\e[m"
      printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
    done
    echo; echo
  done
}

meteo() {
    curl -H "Accept-Language: fr" wttr.in/"${1:-Montpellier}?n2"
}

docker_ip() {
  oldISF=$ISF
  IFS=$'\n'
  containers=`docker ps --format "{{.ID}} {{.Names}} {{.Image}}"` 
  
  echo "ID / NAME (IMAGE) : IP"
  for item in $containers
  do 
    id=`echo $item | cut -d ' ' -f1`
    name=`echo $item | cut -d ' ' -f2`
    image=`echo $item | cut -d ' ' -f3`
    ip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id`
    echo $id" / "$name" ("$image") : "$ip
  done
  IFS=$oldISF
}

docker_dns() {
  docker kill `docker ps -q --filter ancestor=defreitas/dns-proxy-server` &>/dev/null && echo 'Removed old container'

  docker run -d \
  --hostname dns.mageddo \
  --restart=unless-stopped \
  -p 5380:5380 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/resolv.conf:/etc/resolv.conf \
  -e MG_REGISTER_CONTAINER_NAMES=1 \
  defreitas/dns-proxy-server
}

swap_usage() {
    for file in /proc/*/status ; do 
      awk '/VmSwap|Name/{printf $2 " " $3}END{ print "" }' $file; 
  done | sort -k 2 -n -r | head -n 15
}

import_docker_creds_to_kubernetes() {
  namespace=${1:?Missing namespace}
  kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=${HOME}/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson \
    --namespace "$namespace"
  
  echo "Docker config imported as regcred secret in $namespace of $(kubectl config current-context)"
}

battery_level() {
  upower -i `upower -e | grep \'BAT\'`
}

generate_kubeconfig() {
  local base_config="$HOME/.kube/config"
  local base_config_bkp="$HOME/.kube/config.bkp"
  local config_dir="$HOME/.kube/config.d"

  if [ -d "$config_dir" ]; then
    local config_files=$(find "$config_dir" -type f -name "*.yaml" -exec printf ":%s" {} \;)
    local kubeconfig="$base_config$config_files"
    cp $base_config $base_config_bkp

    # Output the KUBECONFIG value
    export KUBECONFIG="$kubeconfig"
    kubectl config view --raw=true > $base_config

    export KUBECONFIG="$base_config"
  else
    # If the directory does not exist, just use the base config
    export KUBECONFIG="$base_config"
  fi
  
}

$*