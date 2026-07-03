#!/bin/bash
# Flomicso Travel Website Deployment Script
# Run this on the server: bash DEPLOY.sh

set -e

echo "=========================================="
echo "Flomicso Travel Website Deployment"
echo "=========================================="

# Configuration
DOMAIN="flomicso.com"
WEBROOT="/var/www/${DOMAIN}"
PORT=3000
REPO_URL="https://github.com/sanmidawodu/travel.git"
BRANCH="claude/flomicso-audit-l0g9fy"

echo ""
echo "Step 1: Verify prerequisites"
echo "=========================================="
echo "Checking Node.js..."
node -v || { echo "Node.js not found. Install with: apt-get install -y nodejs npm"; exit 1; }
npm -v || { echo "npm not found. Install with: apt-get install -y npm"; exit 1; }

echo ""
echo "Step 2: Navigate to webroot"
echo "=========================================="
cd ${WEBROOT}
echo "Current directory: $(pwd)"

echo ""
echo "Step 3: Create backup"
echo "=========================================="
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="${WEBROOT}/backup-${TIMESTAMP}"
mkdir -p backups
cp -r ./ "./backups/backup-${TIMESTAMP}" 2>/dev/null || true
echo "✓ Backup created: backups/backup-${TIMESTAMP}"

echo ""
echo "Step 4: Pull latest code from repository"
echo "=========================================="
if [ -d .git ]; then
    echo "Git repository exists, pulling latest code..."
    git fetch origin
    git checkout ${BRANCH}
    git pull origin ${BRANCH}
else
    echo "Cloning repository..."
    cd /tmp
    git clone ${REPO_URL} travel-temp
    cd travel-temp
    git checkout ${BRANCH}
    cp -r ./* ${WEBROOT}/
    cd ${WEBROOT}
    rm -rf /tmp/travel-temp
fi

echo "✓ Code updated"

echo ""
echo "Step 5: Install dependencies"
echo "=========================================="
npm install --production
echo "✓ Dependencies installed"

echo ""
echo "Step 6: Stop existing process (if running)"
echo "=========================================="
# Kill any existing Node process on port 3000
lsof -ti:${PORT} | xargs kill -9 2>/dev/null || true
echo "✓ Old processes cleaned up"

echo ""
echo "Step 7: Start the application"
echo "=========================================="
echo "Starting Node.js server on port ${PORT}..."

# Option 1: Using PM2 (recommended for production)
if command -v pm2 &> /dev/null; then
    pm2 delete flomicso-travel 2>/dev/null || true
    pm2 start server.js --name "flomicso-travel" --env NODE_ENV=production
    pm2 save
    echo "✓ Server started with PM2"
    pm2 status
else
    echo "PM2 not found. Installing..."
    npm install -g pm2
    pm2 start server.js --name "flomicso-travel" --env NODE_ENV=production
    pm2 save
    pm2 startup
    echo "✓ Server started with PM2"
fi

echo ""
echo "Step 8: Test the application"
echo "=========================================="
sleep 2
echo "Testing API endpoints..."

# Test hotels endpoint
HOTELS=$(curl -s http://localhost:${PORT}/api/hotels | head -c 100)
if [[ $HOTELS == *"Luxury Paradise Resort"* ]]; then
    echo "✓ /api/hotels - WORKING"
else
    echo "✗ /api/hotels - FAILED"
fi

# Test packages endpoint
PACKAGES=$(curl -s http://localhost:${PORT}/api/packages | head -c 100)
if [[ $PACKAGES == *"Bali"* ]]; then
    echo "✓ /api/packages - WORKING"
else
    echo "✗ /api/packages - FAILED"
fi

# Test activities endpoint
ACTIVITIES=$(curl -s http://localhost:${PORT}/api/activities | head -c 100)
if [[ $ACTIVITIES == *"Scuba"* ]]; then
    echo "✓ /api/activities - WORKING"
else
    echo "✗ /api/activities - FAILED"
fi

echo ""
echo "Step 9: Configure Nginx (if needed)"
echo "=========================================="
if ! [ -f /etc/nginx/sites-available/${DOMAIN} ]; then
    echo "Creating Nginx configuration..."
    sudo tee /etc/nginx/sites-available/${DOMAIN} > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    listen 443 ssl http2;
    server_name flomicso.com www.flomicso.com;

    # SSL certificates (uncomment if using Let's Encrypt)
    # ssl_certificate /etc/letsencrypt/live/flomicso.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/flomicso.com/privkey.pem;

    # Redirect HTTP to HTTPS (uncomment if SSL is set up)
    # if ($scheme != "https") {
    #     return 301 https://$server_name$request_uri;
    # }

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINX_CONFIG

    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/

    # Test Nginx config
    if sudo nginx -t; then
        sudo systemctl reload nginx
        echo "✓ Nginx configured and reloaded"
    else
        echo "✗ Nginx configuration error - review manually"
    fi
else
    echo "✓ Nginx already configured for ${DOMAIN}"
fi

echo ""
echo "=========================================="
echo "✓ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "Website Information:"
echo "  Domain: https://${DOMAIN}"
echo "  API Base: https://${DOMAIN}/api/"
echo "  Server: localhost:${PORT}"
echo ""
echo "API Endpoints:"
echo "  Hotels:    https://${DOMAIN}/api/hotels"
echo "  Packages:  https://${DOMAIN}/api/packages"
echo "  Activities: https://${DOMAIN}/api/activities"
echo "  Search:    https://${DOMAIN}/api/search?destination=Bali"
echo ""
echo "Management:"
echo "  View logs:  pm2 logs flomicso-travel"
echo "  Restart:    pm2 restart flomicso-travel"
echo "  Stop:       pm2 stop flomicso-travel"
echo "  Backup:     Check backups/ directory"
echo ""
echo "Support: See DEPLOYMENT.md for more options"
echo "=========================================="
