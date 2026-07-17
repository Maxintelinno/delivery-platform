require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  connectionTimeoutMillis: 10000,
  idleTimeoutMillis: 10000,
});
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });
const app = express();
const http = require('http');
const server = http.createServer(app);
const io = require('socket.io')(server, { cors: { origin: '*' } });
const PORT = process.env.PORT || 3000;

io.on('connection', (socket) => {
  console.log('A client connected');
  socket.on('disconnect', () => {
    console.log('A client disconnected');
  });
});

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    message: "Delivery Platform API is running!",
    environment: process.env.NODE_ENV || "development"
  });
});

// Fetch all users
app.get('/api/users', async (req, res) => {
  try {
    const users = await prisma.user.findMany();
    res.json(users);
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// Fetch all merchants
app.get('/api/merchants', async (req, res) => {
  try {
    const merchants = await prisma.merchant.findMany();
    res.json(merchants);
  } catch (error) {
    console.error("Error fetching merchants:", error);
    res.status(500).json({ error: "Failed to fetch merchants" });
  }
});

// Fetch specific merchant by ID with related menu items
app.get('/api/merchants/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ error: "Invalid merchant ID. Must be an integer." });
    }

    const merchant = await prisma.merchant.findUnique({
      where: { id },
      include: {
        menus: true,
      },
    });

    if (!merchant) {
      return res.status(404).json({ error: "Merchant not found" });
    }

    res.json(merchant);
  } catch (error) {
    console.error(`Error fetching merchant with ID ${req.params.id}:`, error);
    res.status(500).json({ error: "Failed to fetch merchant" });
  }
});

// Create a new order
app.post('/api/orders', async (req, res) => {
  try {
    const {
      customerId,
      merchantId,
      items,
      totalAmount,
      deliveryFee,
      netAmount,
      deliveryAddress,
      deliveryLatitude,
      deliveryLongitude,
      paymentMethod,
    } = req.body;

    // Simple validation
    if (!merchantId || !items || !Array.isArray(items) || items.length === 0 || !totalAmount || !deliveryAddress) {
      return res.status(400).json({ error: "Missing required fields or items is empty" });
    }

    let finalCustomerId = customerId ? parseInt(customerId, 10) : null;

    if (!finalCustomerId) {
      // Get or create a default customer user
      let customer = await prisma.user.findFirst({
        where: { role: 'CUSTOMER' },
      });

      if (!customer) {
        customer = await prisma.user.create({
          data: {
            name: 'Default Customer',
            email: 'customer@test.com',
            phone: '0987654321',
            role: 'CUSTOMER',
          },
        });
      }
      finalCustomerId = customer.id;
    }

    // Create the order using a nested write inside a transaction
    const order = await prisma.order.create({
      data: {
        customerId: finalCustomerId,
        merchantId: parseInt(merchantId, 10),
        totalAmount: parseFloat(totalAmount),
        deliveryFee: parseFloat(deliveryFee !== undefined ? deliveryFee : 20),
        netAmount: parseFloat(netAmount !== undefined ? netAmount : (parseFloat(totalAmount) + parseFloat(deliveryFee !== undefined ? deliveryFee : 20))),
        deliveryAddress,
        deliveryLatitude: parseFloat(deliveryLatitude !== undefined ? deliveryLatitude : 13.736717),
        deliveryLongitude: parseFloat(deliveryLongitude !== undefined ? deliveryLongitude : 100.523186),
        paymentMethod: paymentMethod || 'CASH',
        orderItems: {
          create: items.map((item) => ({
            menuId: parseInt(item.menuId, 10),
            quantity: parseInt(item.quantity, 10),
            price: parseFloat(item.price),
            selectedOptions: item.selectedOptions || {},
          })),
        },
      },
      include: {
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    res.status(201).json(order);
  } catch (error) {
    console.error("Error creating order:", error);
    res.status(500).json({ error: "Failed to create order" });
  }
});

// Fetch all orders for a specific merchant
app.get('/api/orders/merchant/:merchantId', async (req, res) => {
  try {
    const merchantId = parseInt(req.params.merchantId, 10);
    if (isNaN(merchantId)) {
      return res.status(400).json({ error: "Invalid merchant ID. Must be an integer." });
    }

    const orders = await prisma.order.findMany({
      where: { merchantId },
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    res.json(orders);
  } catch (error) {
    console.error(`Error fetching orders for merchant with ID ${req.params.merchantId}:`, error);
    res.status(500).json({ error: "Failed to fetch merchant orders" });
  }
});

// Fetch all orders for a specific customer
app.get('/api/orders/customer/:customerId', async (req, res) => {
  try {
    const customerId = parseInt(req.params.customerId, 10);
    if (isNaN(customerId)) {
      return res.status(400).json({ error: "Invalid customer ID. Must be an integer." });
    }

    const orders = await prisma.order.findMany({
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        merchant: true,
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    console.log("Customer orders fetched:", orders.length);
    res.json(orders);
  } catch (error) {
    console.error(`Error fetching orders for customer with ID ${req.params.customerId}:`, error);
    res.status(500).json({ error: "Failed to fetch customer orders" });
  }
});

// Update the status of an order
app.patch('/api/orders/:id/status', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    let { status } = req.body;

    if (isNaN(id)) {
      return res.status(400).json({ error: "Invalid order ID. Must be an integer." });
    }

    if (!status) {
      return res.status(400).json({ error: "Missing status in request body" });
    }

    // Map 'DECLINED' to 'CANCELLED' to fit OrderStatus database enum constraints
    if (status === 'DECLINED') {
      status = 'CANCELLED';
    }

    const updatedOrder = await prisma.order.update({
      where: { id },
      data: { status },
      include: {
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    // Emit real-time order status update to all connected clients
    io.emit('orderStatusUpdated', { orderId: updatedOrder.id, status: updatedOrder.status });

    res.json(updatedOrder);
  } catch (error) {
    console.error(`Error updating status for order with ID ${req.params.id}:`, error);
    res.status(500).json({ error: "Failed to update order status" });
  }
});

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
