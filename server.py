import os
from deepfloyd_if.pipelines import dream
import glob
from flask import Flask, request, jsonify
import base64
from io import BytesIO
import torch
from deepfloyd_if.modules import IFStageI, IFStageII, StableStageIII
from deepfloyd_if.modules.t5 import T5Embedder

app = Flask(__name__)

device="cuda:0"
if_I = IFStageI('IF-I-XL-v1.0', device=device)
if_II = IFStageII('IF-II-L-v1.0', device=device)
#if_III = StableStageIII('stable-diffusion-x4-upscaler', device=device)
t5 = T5Embedder(device=device)


def save_image(image, stage):
    output_dir = "output"
    os.makedirs(output_dir, exist_ok=True)
    image_files = glob.glob(os.path.join(output_dir, f"*-stage{stage}.png"))
    image_count = len(image_files) + 1
    image_path = os.path.join(output_dir, f"{image_count:05d}-stage{stage}.png")
    image.save(image_path)
    return image_path


@app.route('/generate_image', methods=['POST'])
def generate_image():
    stage = int(request.form.get('stage'))
    prompt = request.form.get('prompt')
    print(prompt)
    count=1
    result = dream(
        t5=t5, if_I=if_I, if_II=if_II, if_III=None,
        disable_watermark=True,
        negative_prompt="stupid, lame",
        style_prompt="very profound, deep, inspiring",
        prompt=[prompt]*count,
        if_I_kwargs={
            "guidance_scale": 7.0,
            "sample_timestep_respacing": "smart100",
        },
        if_II_kwargs={
            "guidance_scale": 4.0,
            "sample_timestep_respacing": "smart50",
        },
        if_III_kwargs={
            "guidance_scale": 9.0,
            "noise_level": 20,
            "sample_timestep_respacing": "75",
        },
    )
    print(result)
    save_image(result["I"][0], 1)
    save_image(result["II"][0], 2)
    #save_image(result["III"][0], 3)

    # Convert PIL image to base64
    buffered = BytesIO()
    #result["III"][0].save(buffered, format="PNG")
    img_str = base64.b64encode(buffered.getvalue())

    # Return base64 encoded image and image path
    return jsonify({"image": img_str.decode('utf-8')})


if __name__ == '__main__':
    app.run()
