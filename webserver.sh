#!/usr/bin/env bash

# Team:
# Guus - 1045891
# Omar - 1058647

# Define global variable here

# TODO: : Add required and additional packagenas dependecies 
# for your implementation
# declare -a packages=()

# Omar
# TODO: : define a function to handle errors
# This funtion accepts two parameters one as the error message and one as the command to be excecuted when error occurs.
function handle_error() {
    # Do not remove next line!
    echo "function handle_error"

   # TODO:  Display error and return an exit code
    echo "Error: $1"
    exit ${2:-1}
}

# Omar
# Function to solve dependencies
function setup() {
    # Do not remove next line!
    echo "function setup"

    # TODO:  check if nessassary dependecies and folder structure exists and 
    # print the outcome for each checking step
    # TODO:  check if required dependency is not already installed otherwise install it
    # if a a problem occur during the this process 
    # use the function handle_error() to print a messgage and handle the error
    echo ""
    echo "Checking dependencies..."
    dependencies=("unzip" "wget" "curl")
    for dependency in "${dependencies[@]}"; do
        if ! command -v "$dependency"; then
            echo "$dependency is not installed, installing..."

            # Install dependency
            if ! sudo apt-get install -y "$dependency"; then
                handle_error "Failed to install $dependency"
            fi
        
            echo "$dependency installation finished"
        else
            echo "$dependency is installed"
        fi
    done
    
    
    # TODO:  check if required folders and files exists before installations
    # For example: the folder ./apps/ and the file "dev.conf"
    echo ""
    echo "Checking folders and files..."
    if [ ! -d ~/apps ]; then
    echo "Creating ~/apps directory..."
    mkdir ~/apps
    fi

    if [ ! -f ~/apps/dev.conf ]; then
        echo "Creating ~/apps/dev.conf file..."
        touch ~/apps/dev.conf
    fi

    echo "Process complete"

    # TODO:  installation from online package requires values for
    # package_name package_url install_dir
    



}

# Guus
# Function to install a package from a URL
# TODO:  assign the required parameter needed for the logic
# complete the implementation of the following function.
function install_package() {
    # Do not remove next line!
    echo "function install_package"

    if [ $# -ne 3 ]; then
        handle_error "Invalid number of arguments"
    fi

    package_name=$1
    package_url=$2
    install_dir=$3

    # TODO:  The logic for downloading from a URL and unizpping the downloaded files of different applications must be generic

    # TODO:  Specific actions that need to be taken for a specific application during this process should be handeld in a separate if-else

    # TODO:  Every intermediate steps need to be handeld carefully. error handeling should be dealt with using handle_error() and/or rollback()

    # TODO:  If a file is downloaded but cannot be zipped a rollback is needed to be able to start from scratch
    # for example: package names and urls that are needed are passed or extracted from the config file

    # TODO:  check if the application-folder and the url of the dependency exist
    echo "Validating install dir..."
    if [ ! -d $install_dir ]; then
        mkdir $install_dir
    fi

    echo "Validating package URL..."
    if ! wget -q --method=HEAD $package_url; then
        handle_error "Package URL is invalid"
    fi

    # TODO:  create a specific installation folder for the current package
    echo "Creating package dir..."
    mkdir "$install_dir/$package_name"

    # TODO:  Download and unzip the package
    # if a a problem occur during the this proces use the function handle_error() to print a messgage and handle the error
    echo "Downloading package..."
    if ! wget -O "$package_name.zip" $package_url; then
        handle_error "Failed to download package"
    fi
   
    # TODO:  extract the package to the installation folder and store it into a dedicated folder
    # If a problem occur during the this proces use the function handle_error() to print a messgage and handle the error
    echo "Unzipping files..."
    if ! unzip -j "$package_name.zip" -d "$install_dir/$package_name"; then
        "rollback_$package_name" $install_dir
        handle_error "Failed to unzip package"
    fi

    rm "$package_name.zip"

    # TODO:  this section can be used to implement application specifc logic
    # nosecrets might have additional commands that needs to be executed
    # make sure the user is allowed to remove this folder during uninstall
    if [ $package_name == "nosecrets" ]; then
        echo "Running nosecrets extra installation steps"
        cd "$install_dir/$package_name"

        echo "Moving all source files to ./src"
        mkdir src
        for f in *; do
            ext=${f: -2}
            if [ $ext == ".h" ] || [ $ext == ".c" ]; then
                mv $f "src/$f"
                echo "Moved $f"
            fi
        done

        echo "Making..."
        if ! make nms; then
            handle_error "Failed to make nms"
        fi

        echo "Installing..."
        if ! sudo make install; then
            handle_error "Failed to install"
        fi

        cd ../..
        echo "Extra installation steps completed"
    fi

    echo "Installed $package_name"
}

# Omar
function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    # TODO:  rollback intermiediate steps when installation fails
    if [ -d "$1/nosecrets" ]; then
        rm -rf "$1/nosecrets"
    fi

    if [ -e nosecrets.zip ]; then
        rm nosecrets.zip
    fi

    echo "Rolled back nosecrets"
}

# Guus
function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    # TODO:  rollback intermiediate steps when installation fails
    if [ -d "$1/pywebserver" ]; then
        rm -rf "$1/pywebserver"
    fi

    if [ -e pywebserver.zip ]; then
        rm pywebserver.zip
    fi

    echo "Rolled back pywebserver"
}

# Omar
function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

    # TODO:  test nosecrets
     echo "Running 'ls -l | nms'..."
    ls -l | nms

    # Check the exit status of the command
    if [ $? -eq 0 ]; then
        echo "Test passed."
    else
        handle_error "Test failed."
    fi

}

# Guus
function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"

    host="$2:$3"

    # TODO:  test the webserver
    # server and port number must be extracted from config.conf
    if [ ! -e "$1/pywebserver/webserver" ]; then
        handle_error "pywebserver executable not found"
    fi

    "./$1/pywebserver/webserver" $host &
    pid=$!

    echo "Started pywebserver on $host with PID: $pid"

    # test data must be read from test.json
    data=$(<test.json)

    echo "Sending test request to server..."

    max_tries=100
    failed=false

    for ((i = 1; i <= max_tries; i++)); do
        res=$(curl -s -X POST "http://localhost:$3" -d "$data")

        last=$(echo $res | tail -n 1)

        if [[ $last == $data ]]; then
            echo "Successfully received response from the server"
            break
        fi

        if [ $i == $max_tries ]; then
            failed=true
        fi
    done

    if [ $failed == true ]; then
        handle_error "Failed to connect to webserver"
    fi

    # kill this webserver process after it has finished its job
    kill $pid

    echo "Pywebserver works as intended"
}

# Omar
function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"  

    #TODO:  uninstall nosecrets application
    if [ -d "$1/nosecrets" ]; then
        cd "apps/nosecrets"
        sudo make uninstall
        cd ../..
        rm -rf "$1/nosecrets"
    fi

    echo "Uninstalled nosecrets"
}

# Guus
function uninstall_pywebserver() {
    # Do not remove next line!
    echo "function uninstall_pywebserver"

    #TODO:  uninstall pywebserver application
    if [ -d "$1/pywebserver" ]; then
        rm -rf "$1/pywebserver"
    fi

    echo "Uninstalled pywebserver"
}

# Omar
#TODO:  removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"

    if [ -d "$INSTALL_DIR/nosecrets" ] || [ -d "$INSTALL_DIR/pywebserver" ]; then
        handle_error "Uninstall the apps first before removing dependecies"
    fi

    # Remove each package that was installed during setup
    echo "Removing dependencies..."
    dependencies=("unzip" "wget" "curl")
    for dependency in "${dependencies[@]}"; do
        if command -v "$dependency"; then
            echo "Uninstalling $dependency..."
            sudo apt-get remove -y "$dependency"
        fi
    done

    # Remove the directories and files that were created during setup
    echo "Removing directories and files..."
    if [ -d ~/apps ]; then
        echo "Removing ~/apps directory..."
        rm -rf ~/apps
    fi

    echo "Process complete"
}

# Guus
function main() {
    # Do not remove next line!
    echo "function main"

    # TODO: 
    # Read global variables from configfile

    if [ ! -e dev.conf ]; then
        handle_error "dev.conf not found"
    fi

    . dev.conf

    # Get arguments from the commandline
    # Check if the first argument is valid
    # allowed values are "setup" "nosecrets" "pywebserver" "remove"
    # bash must exit if value does not match one of those values

    # Check if the second argument is provided on the command line
    # Check if the second argument is valid
    # allowed values are "--install" "--uninstall" "--test"
    # bash must exit if value does not match one of those values

    # Execute the appropriate command based on the arguments
    # TODO:  In case of setup
    # excute the function check_dependency and provide necessary arguments
    # expected arguments are the installation directory specified in dev.conf

    if [[ "$1" != "setup" && "$1" != "nosecrets" && "$1" != "pywebserver" && "$1" != "remove" ]]; then
        handle_error "Invalid command: $1"
    fi

    if [ $1 == "setup" ]; then
        setup
    elif [ $1 == "remove" ]; then
        remove $INSTALL_DIR
    elif [ $1 == "nosecrets" ]; then
        if [ $2 == "--install" ]; then
            install_package nosecrets $APP1_URL $INSTALL_DIR
        elif [ $2 == "--uninstall" ]; then
            uninstall_nosecrets $INSTALL_DIR
        elif [ $2 == "--test" ]; then
            test_nosecrets $INSTALL_DIR
        else
            handle_error "Invalid option: $2"
        fi
    elif [ $1 == "pywebserver" ]; then
        if [ $2 == "--install" ]; then
            install_package pywebserver $APP2_URL $INSTALL_DIR
        elif [ $2 == "--uninstall" ]; then
            uninstall_pywebserver $INSTALL_DIR
        elif [ $2 == "--test" ]; then
            test_pywebserver $INSTALL_DIR $WEBSERVER_IP $WEBSERVER_PORT
        else
            handle_error "Invalid option: $2"
        fi
    else
        handle_error "Invalid command: $1"
    fi
}

# Pass commandline arguments to function main
main "$@"