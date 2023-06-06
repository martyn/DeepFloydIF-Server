# Use the specified base image
FROM runpod/pytorch:3.10-1.13.1-116-devel

# Clone the required repositories and install dependencies
RUN git clone https://github.com/deep-floyd/IF.git /IF

RUN cd /IF && pip3 install -r requirements.txt
RUN pip3 install flask xformers==0.0.16
RUN pip3 install git+https://github.com/openai/CLIP.git --no-deps

RUN git clone https://github.com/martyn/DeepFloydIF-Server /IF/server && \
    mv /IF/server/* /IF

RUN echo 'echo "Welcome to DeepFloyd IF runpod."' >> /root/.bashrc
RUN echo 'echo ""' >> /root/.bashrc
RUN echo 'echo "You need to login to huggingface with \`huggingface-cli login\`."' >> /root/.bashrc
RUN echo 'echo "Then \`./generate.sh \"An app logo of featuring an apple tree\"\`"' >> /root/.bashrc
WORKDIR /IF
RUN mkdir /IF/output

CMD ["python3", "server.py"]
