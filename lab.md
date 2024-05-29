### Deep Dive into Linux AWS Fundamentals: Hands-On

1. Intro to Linux AWS Fundamentals
2. Create EC2 Linux
3. Getting started with Linux CLI
4. Create HTTPD web server
5. Add EBS and create LVM

########################################################################

### Lab 1. Install and configure httpd server

########################################################################

### Create a web server using any template from the "ecommerce" repository.
1. Clone the course repository ``https://github.com/kendopx/ecommerce.git`` to your local machine.
2. Copy the web content from the **ecommerce/html**  to your Web server DocumentRoot folder.
3. Install Nginx or Apache HTTP Server (httpd) to serve as your web server for hosting your portfolio web page.
4. Test your website using the IP address of your VM or instance.

### Step 1. Install git and clone repositories
sudo yum -y install httpd git 
git clone https://github.com/kendopx/ecommerce.git
sleep 15s
ls -lrt

### Step 2. Rename existing html directory and replace it with new one
mv /var/www/html /var/www/html_old
cp -r ecommerce/html  /var/www/

### Step 3. Stop/Start/status/enable httpd service
sudo systemctl stop httpd
sudo systemctl start httpd
sudo systemctl status httpd
sudo systemctl enable httpd

