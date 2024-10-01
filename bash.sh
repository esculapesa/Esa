#!/bin/bash

# Function to check if a string is a valid IP address
is_ip() {
    local ip="$1"
    # Check if the input matches the format of an IP address
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0  # It is an IP address
    else
        return 1  # It is not an IP address
    fi
}

# Function to get IP address from DDNS or return the input if it is already an IP address
get_ip_from_ddns() {
    local ddns_name="$1"
    local ip

    if is_ip "$ddns_name"; then
        ip="$ddns_name"
    else
        # Use nslookup to get the IP address
        ip=$(nslookup "$ddns_name" | awk '/^Address: / { print $2 }' | tail -n1)
    fi

    if [ -z "$ip" ]; then
        echo "No IP address found for $ddns_name"
        return 1
    else
        echo "$ip"
    fi
}

# Function to detect if running on Windows (Git Bash)
is_windows() {
    case "$(uname -s)" in
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

esacoin() {
    local prefix=""
    local ipc_path="/root/.esa/geth.ipc"
    local bash_path="/bin/bash"
    local conv_ip=$(get_ip_from_ddns "$this_ip")
    
    if is_windows; then
        prefix="winpty"
    fi

    convert_path() {
        if is_windows; then
            # Convert /path/to to //path//to
            echo "$1" | sed 's,/,//,g'
        else
            echo "$1"
        fi
    }

    if [ "$1" = "exec" ]; then
        if [ "$2" = "bash" ]; then
            ${prefix} docker exec -it esanode $(convert_path "$bash_path")
        else
            ${prefix} docker exec -it esanode ./build/bin/geth attach ipc:$(convert_path "$ipc_path")
        fi
    elif [ "$1" = "run" ]; then
        if [ "$2" = "sh" ]; then
            docker run --name esanode -d -p 8545:8545 -p 30303:30303 -p 8546:8546 -v ${this_root_path}:/root/.esa -e IP=$conv_ip esacoin/esanode:latest sh
        elif [ "$2" = "tag" ]; then
            docker run --name esanode -d -p 8545:8545 -p 30303:30303 -p 8546:8546 -v ${this_root_path}:/root/.esa -e IP=$conv_ip esacoin/esanode:$3
        else
            docker run --name esanode --log-driver=json-file --log-opt max-size=10m --log-opt max-file=3  -d -p 8545:8545 -p 30303:30303 -p 8546:8546 -v ${this_root_path}:/root/.esa -e IP=$conv_ip -e OPTIONS="$OPTIONS" esacoin/esanode:latest
        fi
    elif [ "$1" = "stop" ]; then
        if [ "$2" = "only" ]; then
            docker stop esanode
        else
            docker stop esanode
            docker rm esanode
        fi
    elif [ "$1" = "docker" ]; then
        if [ "$2" = "build" ]; then
            docker build -t esacoin/esanode:latest .
        elif [ "$2" = "pull" ]; then
            docker pull esacoin/esanode:latest
        elif [ "$2" = "push" ]; then
            docker push esacoin/esanode:latest
        else
            docker ps
        fi
    elif [ "$1" = "clean" ]; then
        sudo rm -rf $this_root_path
        if [ "$2" = "all" ]; then
            docker stop $(docker ps -q)
            docker rm $(docker ps -a -q)
            docker rmi $(docker images -q)
            docker volume rm $(docker volume ls -q)
            docker network rm $(docker network ls -q)
            docker system prune -a --volumes
        fi
    fi
}
