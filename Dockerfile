FROM amazon/dynamodb-local
USER root
ENV AWS_ACCESS_KEY_ID=foo
ENV AWS_SECRET_ACCESS_KEY=bar

RUN \
    yum update -q -y \
    && yum install -q -y sysvinit-tools unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

COPY ./create-tables.sh .

RUN \
    mkdir /db \
    && java -jar DynamoDBLocal.jar -dbPath /db -sharedDb 2>&1 \
    & echo "Starting DynamoDB Local" \
    && ./create-tables.sh \
    && pid=$( pidof java ) \
    && echo "Killing DynamoDB Local ($pid)" \
    && kill $pid \
    && while [ -e "/proc/$pid" ]; do sleep 1; done