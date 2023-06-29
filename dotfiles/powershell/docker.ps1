function aerc {
  new-item -itemtype directory ~/.password-store -erroraction silentlycontinue

  docker volume ls | grep -q aerc || docker volume create aerc

  docker run -it --rm --name aerc `
    -e EDITOR=/usr/bin/vim `
    -v aerc:/home/aerc `
    -e TZ=America/Denver `
    --network host `
    docker.io/heywoodlh/aerc:latest $argv
}

function gomuks {
    New-Item -ItemType Directory -Path ${HOME}/tmp 2> $null
    New-Item -ItemType Directory -Path ${HOME}/Downloads 2> $null
    New-Item -ItemType Directory -Path ${HOME}/.local/gomuks/config 2> $null
    New-Item -ItemType Directory -Path ${HOME}/.local/gomuks/cache 2> $null
    New-Item -ItemType Directory -Path ${HOME}/.local/gomuks/share 2> $null

    docker run --rm -it -e TZ=America/Denver -e TMUX='' -v ${HOME}/.local/gomuks/cache:/home/gomuks/.cache/gomuks -v ${HOME}/.local/gomuks/share:/home/gomuks/.local/share/gomuks -v ${HOME}/.local/gomuks/config:/home/gomuks/.config/gomuks -v ${HOME}/Downloads:/home/gomuks/Downloads -v ${HOME}/tmp:/tmp docker.io/heywoodlh/gomuks $args
}

function nix {
    docker run -it --rm -e TZ=America/Denver -v ${PWD}:/workdir -w /workdir docker.io/nixos/nix:latest nix $args
}
