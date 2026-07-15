const http = require('http');

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  const responseData = {
    message: "Delivery Platform API is running!",
    environment: process.env.NODE_ENV || "development"
  };
  res.end(JSON.stringify(responseData));
});

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
