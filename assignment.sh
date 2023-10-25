#!/usr/bin/env bash

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
        if ! command -v "$dependency" >/dev/null 2>&1; then
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
        handle_error "Install dir not found"
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
    if ! wget -O "$package_name.zip" package_url; then
        handle_error "Failed to download package"
    fi

    # TODO:  extract the package to the installation folder and store it into a dedicated folder
    # If a problem occur during the this proces use the function handle_error() to print a messgage and handle the error
    echo "Unzipping files..."
    if ! unzip -j "$package_name.zip" -d "$install_dir/$package_name"; then
        handle_error "Failed to unzip package"
    fi

    rm "$package_name.zip"

    # TODO:  this section can be used to implement application specifc logic
    # nosecrets might have additional commands that needs to be executed
    # make sure the user is allowed to remove this folder during uninstall
    if [ $package_name == "nosecrets" ]; then
        echo "Running nosecrets extra installation steps"
        cd "$install_dir/$package_name"

        if ! make nms; then
            handle_error "Failed to make nms"
        fi

        if ! sudo make install; then
            handle_error "Failed to install"
        fi

        echo "Extra installation steps completed"
    fi

    echo "Installed $package_name"
}

# Omar
function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    # TODO:  rollback intermiediate steps when installation fails
}

# Guus
function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    # TODO:  rollback intermiediate steps when installation fails
}

# Omar
function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

    # TODO:  test nosecrets
    # kill this webserver process after it has finished its job

}

# Guus
function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"    

    # TODO:  test the webserver
    # server and port number must be extracted from config.conf
    # test data must be read from test.json  
    # kill this webserver process after it has finished its job

}

# Omar
function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"  

    #TODO:  uninstall nosecrets application
}

# Guus
function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"    
    #TODO:  uninstall pywebserver application
}

# Omar
#TODO:  removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"

    # Remove each package that was installed during setup

}

# Guus
function main() {
    # Do not remove next line!
    echo "function main"

    # TODO: 
    # Read global variables from configfile

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

}

# Pass commandline arguments to function main
# main "$@"
install_package "webserver" "https://github.com/nickjj/webserver/archive/refs/heads/master.zip" "./apps"
install_package "nosecrets" "https://github.com/bartobri/no-more-secrets/archive/refs/heads/master.zip" "./apps"