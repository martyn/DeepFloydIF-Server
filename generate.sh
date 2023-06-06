#!/bin/bash

function print_help {
    echo "Usage: $0 prompt output_path [num_iterations] [stage]"
    echo ""
    echo "Arguments:"
    echo "  prompt          The prompt to be used for generating the image."
    echo "  output_path     The path where the output files will be saved."
    echo "  num_iterations  Optional. The number of times to run the loop. Default is 1."
    echo "  stage           Optional. The stage parameter to be used in the request. Default is 2."
    exit 1
}

if [[ -z "$1" || -z "$2" || "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
fi

# The first argument is the prompt.
prompt=$1

# The second argument is the output path.
output_path=$2

# The third argument is the number of times to run the loop. If it is not provided, default to 1.
num_iterations=${3:-1}

# The fourth argument is the stage parameter. If it is not provided, default to 2.
stage=${4:-2}

for ((i=0; i<$num_iterations; i++))
do
  hex=$(openssl rand -hex 3) # Generate a 3-byte (6 characters) random hexadecimal number
  if ! curl -f -s -S -X POST -F "stage=$stage" -F "prompt=$prompt" http://localhost:5000/generate_image -o "$output_path/apple-$hex.png"; then
    echo "Error: curl command failed. Please check your server status or the provided arguments."
    exit 1
  fi
done
