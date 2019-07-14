#!/bin/bash

set -e

CATALINA_HOME=/usr/share/tomcat-codedeploy
TOMCAT_VERSION=8.5.43

# Tar file name
TOMCAT_CORE_TAR_FILENAME="apache-tomcat-$TOMCAT_VERSION.tar.gz"
# Download URL for Tomcat7 core
TOMCAT_CORE_DOWNLOAD_URL="https://www-us.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/$TOMCAT_CORE_TAR_FILENAME"
# The top-level directory after unpacking the tar file
TOMCAT_CORE_UNPACKED_DIRNAME="apache-tomcat-$TOMCAT_VERSION"


# Check whether there exists a valid instance
# of Tomcat8 installed at the specified directory
[[ -d $CATALINA_HOME ]] && { service tomcat status; } && {
    echo "Tomcat8 is already installed at $CATALINA_HOME. Skip reinstalling it."
    exit 0
}

# Clear install directory
if [ -d $CATALINA_HOME ]; then
    rm -rf $CATALINA_HOME
fi
mkdir -p $CATALINA_HOME

# Download the latest Tomcat version
cd /tmp
{ which wget; } || { yum install wget; }
wget $TOMCAT_CORE_DOWNLOAD_URL
if [[ -d /tmp/$TOMCAT_CORE_UNPACKED_DIRNAME ]]; then
    rm -rf /tmp/$TOMCAT_CORE_UNPACKED_DIRNAME
fi
tar xzf $TOMCAT_CORE_TAR_FILENAME

# Copy over to the CATALINA_HOME
cp -r /tmp/$TOMCAT_CORE_UNPACKED_DIRNAME/* $CATALINA_HOME

# Install Java if not yet installed
{ which java; } || { yum install java; }

# Create the service init.d script
cat > /etc/init.d/tomcat7 <<'EOF'
#!/bin/bash
# description: Tomcat Start Stop Restart
# processname: tomcat
PATH=$JAVA_HOME/bin:$PATH
export PATH
CATALINA_HOME='/usr/share/tomcat-codedeploy'
