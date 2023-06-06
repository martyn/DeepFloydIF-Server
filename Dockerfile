# Use the specified base image
FROM runpod/pytorch:3.10-1.13.1-116-devel


# Clone the required repositories and install dependencies
RUN git clone https://github.com/deep-floyd/IF.git /IF

RUN cd /IF && pip3 install -r requirements.txt
RUN git clone https://github.com/martyn/DeepFloydIF-Server /IF/server && \
    mv /IF/server/* /IF

RUN pip3 install flask
RUN pip3 install xformers==0.0.16
RUN pip3 install git+https://github.com/openai/CLIP.git --no-deps

RUN echo 'echo "Welcome to deepfloyd runpod. Create graphics with ./text2img 'text'."' >> /root/.bashrc
RUN echo 'echo ""' >> /root/.bashrc
RUN echo 'echo "The first run downloads deepfloyd.' >> /root/.bashrc
RUN echo 'echo "There is a webserver hosting images that get generated.' >> /root/.bashrc
RUN echo 'echo "You need to login to huggingface with "huggingface-cli login".' >> /root/.bashrc

CMD ["python3", "/IF/server.py"]
