const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
    // API endpoints
    if (req.url === '/api/hotels' && req.method === 'GET') {
        const hotels = [
            { id: 1, name: 'Luxury Paradise Resort', location: 'Bali', price: 299, rating: '4.8/5' },
            { id: 2, name: 'Ocean View Hotel', location: 'Miami', price: 189, rating: '4.6/5' },
            { id: 3, name: 'Mountain Retreat', location: 'Swiss Alps', price: 349, rating: '4.9/5' },
            { id: 4, name: 'City Central Inn', location: 'New York', price: 199, rating: '4.5/5' },
            { id: 5, name: 'Beach Paradise', location: 'Maldives', price: 399, rating: '5.0/5' },
            { id: 6, name: 'Desert Oasis Hotel', location: 'Dubai', price: 279, rating: '4.7/5' }
        ];
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(hotels));
    } else if (req.url === '/api/packages' && req.method === 'GET') {
        const packages = [
            { id: 1, name: 'Bali 5-Day Adventure', location: 'Bali', price: 899, rating: '4.8/5', description: 'All-inclusive resort stay with activities' },
            { id: 2, name: 'European Grand Tour', location: 'Europe', price: 2499, rating: '4.9/5', description: '10-day tour across 4 countries' },
            { id: 3, name: 'Caribbean Cruise', location: 'Caribbean', price: 1299, rating: '4.7/5', description: '7-day cruise with island stops' },
            { id: 4, name: 'Japan Cultural Tour', location: 'Japan', price: 1799, rating: '4.9/5', description: 'Experience traditional and modern Japan' },
            { id: 5, name: 'African Safari', location: 'Tanzania', price: 1999, rating: '4.8/5', description: '5-day wildlife safari adventure' },
            { id: 6, name: 'Iceland Winter Escape', location: 'Iceland', price: 1299, rating: '4.7/5', description: 'Northern lights and geysers tour' }
        ];
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(packages));
    } else if (req.url === '/api/activities' && req.method === 'GET') {
        const activities = [
            { id: 1, name: 'Scuba Diving', location: 'Great Barrier Reef', price: 129, rating: '4.9/5', duration: '4 hours' },
            { id: 2, name: 'Mountain Hiking', location: 'Colorado Rockies', price: 89, rating: '4.8/5', duration: '6 hours' },
            { id: 3, name: 'City Food Tour', location: 'Bangkok', price: 59, rating: '4.7/5', duration: '3 hours' },
            { id: 4, name: 'Helicopter Tour', location: 'New Zealand', price: 199, rating: '4.9/5', duration: '2 hours' },
            { id: 5, name: 'Cooking Class', location: 'Italy', price: 79, rating: '4.8/5', duration: '4 hours' },
            { id: 6, name: 'Sunset Cruise', location: 'Greece', price: 99, rating: '4.7/5', duration: '2 hours' }
        ];
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(activities));
    } else if (req.url.startsWith('/api/search') && req.method === 'GET') {
        // Search endpoint
        const url = new URL(req.url, `http://${req.headers.host}`);
        const destination = url.searchParams.get('destination') || '';

        const mockHotels = [
            { id: 1, name: 'Luxury Paradise Resort', location: 'Bali', price: 299, rating: '4.8/5' },
            { id: 2, name: 'Ocean View Hotel', location: 'Miami', price: 189, rating: '4.6/5' },
            { id: 3, name: 'Mountain Retreat', location: 'Swiss Alps', price: 349, rating: '4.9/5' },
        ];

        const results = mockHotels.filter(h =>
            h.location.toLowerCase().includes(destination.toLowerCase())
        );

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(results));
    } else {
        // Serve static files
        let filePath = req.url === '/' ? '/index.html' : req.url;
        filePath = path.join(__dirname, filePath);

        fs.readFile(filePath, (err, content) => {
            if (err) {
                res.writeHead(404, { 'Content-Type': 'text/html' });
                res.end('<h1>404 - File Not Found</h1>');
            } else {
                const ext = path.extname(filePath);
                let contentType = 'text/html';
                if (ext === '.css') contentType = 'text/css';
                if (ext === '.js') contentType = 'application/javascript';

                res.writeHead(200, { 'Content-Type': contentType });
                res.end(content);
            }
        });
    }
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
    console.log('Press Ctrl+C to stop the server');
});
