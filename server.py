from flask import Flask, request, send_file
import base64
import glob
import io
import os
import torch
from deepfloyd_if.modules import IFStageI, IFStageII, StableStageIII
from deepfloyd_if.modules.t5 import T5Embedder
from deepfloyd_if.pipelines import dream

app = Flask(__name__)

device="cuda:0"
if_I = None
if_II = None
t5 = None

@app.route('/', methods=['GET'])
def index():
    return ""

@app.route('/generate_image', methods=['POST'])
def generate_image():
    global if_I, if_II, if_III, t5
    stage = int(request.form.get('stage'))
    prompt = request.form.get('prompt')
    count=1
    if if_I is None:
        if_I = IFStageI('IF-I-XL-v1.0', device=device)
        if_II = IFStageII('IF-II-L-v1.0', device=device)
        #if_III = StableStageIII('stable-diffusion-x4-upscaler', device=device)
        t5 = T5Embedder(device=device)


    result = dream(
        t5=t5, if_I=if_I, if_II=if_II, if_III=if_III,
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

    stage_str = "II"
    if stage == 1:
        stage_str = "I"
    byte_arr = io.BytesIO()
    img = result[stage_str][0]
    img.save(byte_arr, format='PNG')
    byte_arr = byte_arr.getvalue()

    print(f"Image created: {image_path}")

    return send_file(
        io.BytesIO(byte_arr),
        mimetype='image/png'
    )


if __name__ == '__main__':
    port=5001
    app.run(host='0.0.0.0', port=port)
