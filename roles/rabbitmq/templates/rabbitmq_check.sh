#!/bin/bash

rabbitmqadmin -H {{ansible_ssh_host}} -u admin -p admin show overview > /dev/null 2>&1
if [[ $? == 0 ]];then
    rabbitmqadmin -H {{ansible_ssh_host}} -u admin -p admin declare queue name=test durable=true > /dev/null 2>&1
    rabbitmqadmin -H {{ansible_ssh_host}} -u admin -p admin publish routing_key=test payload="hello world" > /dev/null 2>&1
    rabbitmqadmin -H {{ansible_ssh_host}} -u admin -p admin get queue=test requeue=true > /dev/null 2>&1
    if [[ $? == 0 ]];then
        echo -en "HTTP/1.1 200 OK\r\n"
        echo -en "Content-Type: text/plain\r\n"
        echo -en "Connection: close\r\n"
        echo -en "Content-Length: 35\r\n"
        echo -en "\r\n"
        echo -en "RabbitMQ Node healthcheck passed.\r\n"
        sleep 0.1
        exit 0
    else
        echo -en "HTTP/1.1 503 Service Unavailable\r\n"
        echo -en "Content-Type: text/plain\r\n"
        echo -en "Connection: close\r\n"
        echo -en "Content-Length: 39\r\n"
        echo -en "\r\n"
        echo -en "RabbitMQ Node healthcheck not passed.\r\n"
        sleep 0.1
        exit 1
    fi
else
    echo -en "HTTP/1.1 503 Service Unavailable\r\n"
    echo -en "Content-Type: text/plain\r\n"
    echo -en "Connection: close\r\n"
    echo -en "Content-Length: 39\r\n"
    echo -en "\r\n"
    echo -en "RabbitMQ Node healthcheck not passed.\r\n"
    sleep 0.1
    exit 1
fi
