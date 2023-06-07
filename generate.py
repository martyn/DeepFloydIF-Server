import os
import argparse
import random
import string
import requests
from tqdm import tqdm

def main(args):
    prompt = args.prompt
    num_iterations = args.num_iterations
    stage = args.stage
    output_path = args.output_path

    # Create output directory if it doesn't exist
    os.makedirs(output_path, exist_ok=True)

    for _ in tqdm(range(num_iterations)):
        hex = ''.join(random.choices(string.hexdigits, k=6))  # Generate a 6 characters random hexadecimal number
        payload = {'stage': stage, 'prompt': prompt}

        # Make a POST request
        response = requests.post('http://localhost:5000/generate_image', data=payload)

        # Check if the request was successful
        if response.status_code == 200:
            with open(f"{output_path}/output-{hex}.png", 'wb') as f:
                f.write(response.content)
        else:
            print(f"Error: Request failed with status code {response.status_code}. Response: {response.text}")
            break

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images using a POST request.")
    parser.add_argument("prompt", type=str, help="The prompt to be used for generating the image.")
    parser.add_argument("-n", "--num_iterations", type=int, default=1, help="The number of times to run the loop. Default is 1.")
    parser.add_argument("-s", "--stage", type=int, default=2, help="The stage parameter to be used in the request. Default is 2.")
    parser.add_argument("-o", "--output_path", type=str, default='output', help="The path where the output files will be saved. Default is 'output'.")
    args = parser.parse_args()

    main(args)
