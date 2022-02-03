# Use an official node runtime as a parent image
FROM node:alpine

# Copy the current directory contents into the container at /code
ADD . /code

# Set the working directory to /code
WORKDIR /code

# Install any needed packages specified in package.json
RUN npm install

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variables
# ENV NAME World

# Run ng serve when the container launches
CMD ["node", "server.js"]