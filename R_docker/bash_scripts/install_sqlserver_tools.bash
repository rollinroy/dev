#Import the public repository GPG keys.
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

#Register the Microsoft Ubuntu repository
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

#Update the sources list and run the installation command with the unixODBC developer package.
sudo apt-get update
sudo apt-get install mssql-tools unixodbc-dev

# Note
# To update to the latest version of mssql-tools run the following commands:
sudo apt-get update
sudo apt-get install mssql-tools

# Optional: Add /opt/mssql-tools/bin/ to your PATH environment variable in a bash shell.
#To make sqlcmd/bcp accessible from the bash shell for login sessions, modify your PATH
# in the ~/.bash_profile file with the following command:
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile

#To make sqlcmd/bcp accessible from the bash shell for interactive/non-login sessions, 
# modify the PATH in the ~/.bashrc file with the following command:
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
