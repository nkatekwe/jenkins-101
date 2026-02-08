# Start with a JDK 25 base image and install Jenkins
FROM eclipse-temurin:25-jdk

# Install Jenkins
USER root
RUN apt-get update && apt-get install -y wget lsb-release python3-pip gnupg
RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins.io-2023.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update && apt-get install -y jenkins=2.414.2

# Install Docker CLI
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

# Create jenkins user and setup
RUN useradd -m -d /var/lib/jenkins jenkins
RUN chown -R jenkins:jenkins /var/lib/jenkins /var/log/jenkins /var/cache/jenkins
RUN mkdir -p /usr/share/jenkins/ref/plugins
RUN chown -R jenkins:jenkins /usr/share/jenkins

# Switch to jenkins user
USER jenkins
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000

# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.3 docker-workflow:1.28"

# Expose ports
EXPOSE 8080 50000

# Default command
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
