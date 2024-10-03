#!/bin/bash

# Ensure the script is run from the directory containing go.mod
if [ ! -f ../go.mod ]; then
    echo "go.mod not found in the project root directory. Please run this script from the directory containing go.mod."
    exit 1
fi

echo "Reading modules from go.mod and checking for updates..."

# Prepare to display the table header
printf "%-40s %-20s %-20s\n" "Module" "Current Version" "Latest Version"
printf "%-40s %-20s %-20s\n" "------" "---------------" "--------------"

# Get the list of direct dependencies from go.mod
mapfile -t MODULES < <(go list -m -f '{{if not .Indirect}}{{.Path}} {{.Version}}{{end}}' all)

# Initialize an array to store modules that have updates
declare -a MODULE_UPDATES=()

# For each module, check for available updates
for module_info in "${MODULES[@]}"; do
    module_path=$(echo "$module_info" | awk '{print $1}')
    current_version=$(echo "$module_info" | awk '{print $2}')
    
    # Suppress errors and capture update info
    update_info=$(go list -m -u -f '{{if .Error}}{{else if .Update}}{{.Path}} {{.Version}} {{.Update.Version}}{{end}}' "$module_path" 2>/dev/null)
    
    if [ -n "$update_info" ]; then
        # Extract the latest version
        latest_version=$(echo "$update_info" | awk '{print $3}')
        printf "%-40s %-20s %-20s\n" "$module_path" "$current_version" "$latest_version"
        MODULE_UPDATES+=("$module_path")
    else
        # Check if there was an error
        error_info=$(go list -m -u -f '{{if .Error}}{{.Error.Err}}{{end}}' "$module_path" 2>/dev/null)
        if [ -n "$error_info" ]; then
            printf "%-40s %-20s %-20s\n" "$module_path" "$current_version" "Error"
            echo "Error checking updates for $module_path: $error_info"
        else
            printf "%-40s %-20s %-20s\n" "$module_path" "$current_version" "-"
        fi
    fi
done

# Check if there are modules to update
if [ ${#MODULE_UPDATES[@]} -eq 0 ]; then
    echo ""
    echo "All modules are up to date."
    exit 0
fi

# Ask the user to continue
echo ""
read -p "Do you want to update the above modules to their latest versions? (Y[es]/N[o]): " answer

case "$answer" in
    [Yy]*)
        echo "Updating modules to the latest versions..."
        for module in "${MODULE_UPDATES[@]}"; do
            echo "Updating $module..."
            go get "$module@latest"
        done
        # Run go mod tidy to clean up the go.mod and go.sum files
        go mod tidy
        echo "Modules updated successfully."
        ;;
    *)
        echo "Exiting without updating modules."
        exit 0
        ;;
esac
