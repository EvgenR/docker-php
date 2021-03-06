#!/usr/bin/env bash

die() {
    >&2 echo -e "\033[91m * \033[0m$1";
    exit 128;
}

info() {
    if [[ $2 ]]; then
        echo -en "\033[96m * \033[0m$1";
    else
        echo -e "\033[96m * \033[0m$1";
    fi
}

VERBOSE=""

# Read script options
while getopts hv OPT; do
    case $OPT in
        "h") cat <<HELP
Synopsis: build-php-all-images.sh -v

Options:
  -v <version>  Be verbose
HELP
            exit
            ;;
        "v")
            VERBOSE=1
            ;;
    esac
done


PATHNAMES=$(find php-all -mindepth 2 -maxdepth 2 -type d | sort -V)

for PATHNAME in $PATHNAMES; do
    VERSION=$(echo "$PATHNAME" | awk -F '/' '{print $2}')
    KIND=$(echo "$PATHNAME" | awk -F '/' '{print $3}')

    LOG="build-$VERSION-$KIND.log"


    if [[ $VERBOSE ]]; then
        info "Build bit3/php-all:$VERSION-$KIND"
        docker build -t "bit3/php-all:$VERSION-$KIND" "$PATHNAME" 2>&1 | sed "s/^/ ($VERSION-$KIND) |  /"
    else
        info "Build bit3/php-all:$VERSION-$KIND (@log $LOG)"
        docker build -t "bit3/php-all:$VERSION-$KIND" "$PATHNAME" 2>&1 > "$LOG" || die "failed, see log for details"
    fi
done

