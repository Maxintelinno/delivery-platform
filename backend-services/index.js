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

    io.emit('newOrder', order);
    io.emit('orderCreated', order);
    io.emit('orderStatusUpdated', order);

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

// Fetch all available orders (preparing, no rider assigned)
app.get('/api/orders/available', async (req, res) => {
  try {
    const orders = await prisma.order.findMany({
      where: {
        status: 'PREPARING',
        riderId: null,
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

    console.log("Available orders fetched:", orders.length);
    res.json(orders);
  } catch (error) {
    console.error("Error fetching available orders:", error);
    res.status(500).json({ error: "Failed to fetch available orders" });
  }
});

// Accept an available job by a rider
app.put('/api/orders/:id/accept', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const riderId = parseInt(req.body.riderId, 10);

    if (isNaN(id)) {
      return res.status(400).json({ error: "Invalid order ID. Must be an integer." });
    }

    if (isNaN(riderId)) {
      return res.status(400).json({ error: "Invalid rider ID. Must be an integer." });
    }

    const updatedOrder = await prisma.order.update({
      where: { id },
      data: { riderId },
      include: {
        merchant: true,
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    // Emit Socket.io status update to all client applications
    io.emit('orderStatusUpdated', updatedOrder);

    res.json(updatedOrder);
  } catch (error) {
    console.error(`Error accepting order with ID ${req.params.id}:`, error);
    res.status(500).json({ error: "Failed to accept order" });
  }
});

// Fetch active delivery order for a specific rider
app.get('/api/orders/rider/:riderId/active', async (req, res) => {
  try {
    const riderId = parseInt(req.params.riderId, 10);
    if (isNaN(riderId)) {
      return res.status(400).json({ error: "Invalid rider ID. Must be an integer." });
    }

    const activeOrder = await prisma.order.findFirst({
      where: {
        riderId,
        status: { 
          in: ['PREPARING', 'READY', 'DELIVERING'].map(s => s) // Ensure these match the exact case of your Prisma Enum
        }
      },
      include: {
        merchant: true,
        orderItems: {
          include: {
            menu: true,
          },
        },
      }
    });

    if (!activeOrder) {
      return res.status(404).json({ message: "No active task" });
    }

    res.json(activeOrder);
  } catch (error) {
    console.error(`Error fetching active task for rider with ID ${req.params.riderId}:`, error);
    res.status(500).json({ error: "Failed to fetch active task" });
  }
});

// Fetch order history for a specific rider
app.get('/api/rider/:id/history', async (req, res) => {
  const riderId = parseInt(req.params.id, 10);
  if (isNaN(riderId)) {
    return res.status(400).json({ error: "Invalid rider ID. Must be an integer." });
  }

  const { date } = req.query; // format 'YYYY-MM-DD'

  try {
    let dateFilter = {};
    if (date) {
      const [year, month, day] = date.split('-').map(Number);
      const start = new Date(year, month - 1, day, 0, 0, 0, 0);
      const end = new Date(year, month - 1, day, 23, 59, 59, 999);
      dateFilter = {
        updatedAt: {
          gte: start,
          lte: end
        }
      };
    }

    const historyOrders = await prisma.order.findMany({
      where: { 
        riderId: riderId, 
        status: 'COMPLETED',
        ...dateFilter
      },
      orderBy: { updatedAt: 'desc' },
      include: {
        merchant: true,
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    const totalAmount = historyOrders.reduce((sum, order) => sum + (Number(order.totalAmount) || 0), 0);

    console.log(`[Rider History Debug] Rider ID: ${riderId}, Orders count: ${historyOrders.length}`);
    console.log(`[Rider History Debug] Calculated totalAmount: ฿${totalAmount.toFixed(2)}`);

    res.json({
      orders: historyOrders,
      totalAmount: totalAmount
    });
  } catch (error) {
    console.error(`Error fetching history for rider with ID ${req.params.id}:`, error);
    res.status(500).json({ error: "Failed to fetch history" });
  }
});

// Fetch order history and revenue for a specific merchant
app.get('/api/merchant/:id/history', async (req, res) => {
  const merchantId = parseInt(req.params.id, 10);
  if (isNaN(merchantId)) {
    return res.status(400).json({ error: "Invalid merchant ID. Must be an integer." });
  }

  const { date } = req.query; // format 'YYYY-MM-DD'

  try {
    let dateFilter = {};
    if (date && typeof date === 'string' && date.includes('-')) {
      const parts = date.split('-').map(Number);
      if (parts.length === 3 && !parts.some(isNaN)) {
        const [year, month, day] = parts;
        const start = new Date(year, month - 1, day, 0, 0, 0, 0);
        const end = new Date(year, month - 1, day, 23, 59, 59, 999);
        dateFilter = {
          updatedAt: {
            gte: start,
            lte: end
          }
        };
      }
    }

    const historyOrders = await prisma.order.findMany({
      where: { 
        merchantId: merchantId, 
        status: { in: ['COMPLETED', 'DELIVERED'] },
        ...dateFilter
      },
      orderBy: { updatedAt: 'desc' },
      include: {
        customer: true,
        orderItems: {
          include: {
            menu: true,
          },
        },
      },
    });

    const totalRevenue = historyOrders.reduce((sum, order) => {
      const orderVal = Number(order.totalAmount) || Number(order.netAmount) || 0;
      if (orderVal > 0) return sum + orderVal;
      const itemsVal = (order.orderItems || []).reduce((iSum, item) => iSum + (Number(item.price) * (item.quantity || 1)), 0);
      return sum + itemsVal;
    }, 0);

    console.log(`[Merchant History Debug] Merchant ID: ${merchantId}, Orders count: ${historyOrders.length}`);
    console.log(`[Merchant History Debug] Orders payload:`, JSON.stringify(historyOrders, null, 2));
    console.log(`[Merchant History Debug] Calculated totalRevenue: ฿${totalRevenue.toFixed(2)}`);

    res.json({
      orders: historyOrders,
      totalRevenue: totalRevenue
    });
  } catch (error) {
    console.error(`Error fetching history for merchant with ID ${req.params.id}:`, error);
    res.status(500).json({ error: "Failed to fetch merchant history" });
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

// Update the status of an order via PUT (Rider flow)
app.put('/api/orders/:id/status', async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const { status } = req.body;

    if (isNaN(id)) {
      return res.status(400).json({ error: "Invalid order ID. Must be an integer." });
    }

    if (!status) {
      return res.status(400).json({ error: "Missing status in request body" });
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
    io.emit('orderStatusUpdated', updatedOrder);

    res.json(updatedOrder);
  } catch (error) {
    console.error(`Error updating status via PUT for order with ID ${req.params.id}:`, error);
    res.status(500).json({ error: "Failed to update order status" });
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
