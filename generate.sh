#!/bin/bash

function print_help {
    echo "Usage: $0 prompt [num_iterations] [stage] [output_path]"
    echo ""
    echo "Arguments:"
    echo "  prompt          The prompt to be used for generating the image."
    echo "  num_iterations  Optional. The number of times to run the loop. Default is 1."
    echo "  stage           Optional. The stage parameter to be used in the request. Default is 2."
    echo "  output_path     Optional. The path where the output files will be saved. Default is 'output'."
    exit 1
}

if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
fi

# The first argument is the prompt.
prompt=$1

# The second argument is the number of times to run the loop. If it is not provided, default to 1.
num_iterations=${2:-1}

# The third argument is the stage parameter. If it is not provided, default to 2.
stage=${3:-2}

# The fourth argument is the output path. If it is not provided, default to 'output'.
output_path=${4:-output}

# Create the output directory if it doesn't exist.
mkdir -p $output_path

for ((i=0; i<$num_iterations; i++))
do
  hex=$(openssl rand -hex 3) # Generate a 3-byte (6 characters) random hexadecimal number
  temp_file=$(mktemp) # Create a temporary file
  if ! curl -f -s -S -X POST -F "stage=$stage" -F "prompt=$prompt" http://localhost:5000/generate_image -o $temp_file; then
    echo "Error: curl command failed. Here is the server response:"
    cat $temp_file
    rm $temp_file # Remove the temporary file
    exit 1
  fi
  mv $temp_file "$output_path/image-$hex.png" # Move the temporary file to the final location
done
