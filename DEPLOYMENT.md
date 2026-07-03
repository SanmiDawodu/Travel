# Deployment Guide - Flomicso Travel Website

This guide covers multiple deployment options for the Flomicso Travel website.

## Local Deployment

### Requirements
- Node.js 14+
- npm or yarn

### Steps
```bash
npm install
npm start
```

Website will be available at `http://localhost:3000`

---

## Docker Deployment

### Prerequisites
- Docker installed
- Docker Compose (optional, for easier management)

### Using Docker Compose (Recommended)
```bash
docker-compose up -d
```

The website will be available at `http://localhost:3000`

**Stop the container:**
```bash
docker-compose down
```

### Using Docker directly
```bash
# Build image
docker build -t flomicso-travel .

# Run container
docker run -d -p 3000:3000 --name flomicso flomicso-travel

# Stop container
docker stop flomicso
docker rm flomicso
```

---

## Cloud Deployment Options

### Heroku

1. **Install Heroku CLI**
```bash
npm install -g heroku
heroku login
```

2. **Create and deploy**
```bash
heroku create flomicso-travel
git push heroku main
heroku open
```

3. **View logs**
```bash
heroku logs --tail
```

### Railway.app

1. **Create account** at railway.app
2. **Connect GitHub repository**
3. **Select deployment**
4. **Done** - automatic deployment on git push

### Render.com

1. **Create account** at render.com
2. **New → Web Service**
3. **Connect GitHub repo**
4. **Build & Deploy** with:
   - Build Command: `npm install`
   - Start Command: `npm start`

### AWS (Elastic Beanstalk)

```bash
eb init -p node.js-18 flomicso
eb create flomicso-env
eb deploy
```

### DigitalOcean App Platform

1. **Create new App**
2. **Connect GitHub**
3. **Select repository**
4. **Auto-configure for Node.js**
5. **Deploy**

---

## Environment Variables

Set these in your deployment platform:

```
NODE_ENV=production
PORT=3000
```

---

## Health Checks

The container includes a health check that monitors:
```
GET /api/hotels
```

If this endpoint fails, the container is considered unhealthy.

---

## Performance Optimization

### Enable Caching Headers (in production)
Add to server.js for static files:
```javascript
res.setHeader('Cache-Control', 'public, max-age=3600');
```

### Load Balancing
Deploy multiple instances behind:
- Nginx
- HAProxy
- Cloud load balancers (AWS ALB, GCP LB, Azure LB)

---

## Monitoring & Logging

### Check Container Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs -f web
```

### Health Status
```bash
curl http://localhost:3000/api/hotels
```

---

## Scaling

### Docker Swarm
```bash
docker swarm init
docker stack deploy -c docker-compose.yml flomicso
docker service scale flomicso_web=3
```

### Kubernetes
```bash
kubectl apply -f deployment.yaml
kubectl scale deployment flomicso --replicas=3
```

---

## Database Integration (Future)

When ready to add a database:

1. **Update docker-compose.yml** to include database service
2. **Update server.js** to connect to database
3. **Add environment variables** for connection strings
4. **Deploy with:** `docker-compose up -d`

Example addition to docker-compose.yml:
```yaml
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: flomicso
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  db_data:
```

---

## Troubleshooting

### Port Already in Use
```bash
# Change port
docker run -p 8000:3000 flomicso-travel
```

### Container Won't Start
```bash
# Check logs
docker logs flomicso

# Rebuild
docker build --no-cache -t flomicso-travel .
```

### API Not Responding
```bash
curl http://localhost:3000/api/hotels
# Should return JSON array of hotels
```

### Health Check Failing
Ensure `/api/hotels` endpoint is responding:
```bash
curl -v http://localhost:3000/api/hotels
```

---

## SSL/TLS (HTTPS)

### Using Let's Encrypt with Nginx
```nginx
server {
    listen 443 ssl;
    server_name flomicso.com;
    
    ssl_certificate /etc/letsencrypt/live/flomicso.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/flomicso.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

### Cloud CDN (CloudFlare)
1. Add domain to CloudFlare
2. Enable "Flexible SSL"
3. Update DNS records
4. Automatic HTTPS enabled

---

## Backup & Recovery

### Database Backup
```bash
docker-compose exec db pg_dump -U admin flomicso > backup.sql
```

### Restore
```bash
docker-compose exec -T db psql -U admin flomicso < backup.sql
```

---

## Cost Estimation

| Platform | Cost | Features |
|----------|------|----------|
| Heroku Free | Free (limited) | 1000 dyno hours/month |
| Railway | Pay-as-you-go | Starting $5/mo |
| Render | Free tier available | Starting $7/mo |
| DigitalOcean | $5-100/mo | Scalable |
| AWS | Variable | Highly scalable |

---

## Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Enable HTTPS/SSL
- [ ] Configure logging
- [ ] Set up monitoring
- [ ] Enable backups
- [ ] Configure CDN
- [ ] Set up CI/CD pipeline
- [ ] Test health checks
- [ ] Review error handling
- [ ] Plan scaling strategy

---

For questions or issues, contact: info@flomicso.com
