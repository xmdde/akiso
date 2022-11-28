#!/bin/bash

link=$(curl -s "https://dog.ceo/api/breeds/image/random" | jq -r '.message')
curl -s $link > dog
img2txt dog
rm dog

curl -s https://api.chucknorris.io/jokes/random | jq '.value'