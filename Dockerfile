# Use the specified base image
FROM runpod/pytorch:3.10-1.13.1-116-devel

# Clone the required repositories and install dependencies

#RUN cd /IF && pip3 install -r requirements.txt
RUN apt-get install zip -y

RUN echo 'echo "Welcome to DeepFloyd IF runpod."' >> /root/.bashrc
RUN echo 'echo "To start:"' >> /root/.bashrc
RUN echo 'echo "1. Login to huggingface with \`huggingface-cli login\`."' >> /root/.bashrc
RUN echo 'echo "2. Run \`python3 ./generate.py \"An app logo featuring an apple tree with the words Deep Floyd written underneath\"\`"' >> /root/.bashrc
RUN git clone https://github.com/martyn/DeepFloydIF-Server /IF/

WORKDIR /IF
RUN pip3 install -r requirements.txt
RUN mkdir /IF/models && mv /root/.cache /IF/models/.cache && ln -sf /IF/models/.cache /root/
RUN mkdir /IF/output

CMD ["python3", "-u", "server.py"]
