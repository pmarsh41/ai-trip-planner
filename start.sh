#!/bin/bash

# Trip Planner Startup Script

echo "🚀 Starting AI Trip Planner..."

# Check if we're in the right directory
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Error: Please run this script from the trip_planner directory"
    exit 1
fi

# Start backend in background
echo "📡 Starting backend server..."
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
echo "Backend started with PID: $BACKEND_PID"

# Wait a moment for backend to start
sleep 3

# Kill any process running on port 3000 (React frontend)
PORT=3000
PID_TO_KILL=$(lsof -ti :$PORT)
if [ ! -z "$PID_TO_KILL" ]; then
    echo "🛑 Port $PORT is in use by PID $PID_TO_KILL. Killing it..."
    kill $PID_TO_KILL
    sleep 2
fi

# Start frontend
echo "🎨 Starting frontend..."
cd ../frontend
npm start &
FRONTEND_PID=$!
echo "Frontend started with PID: $FRONTEND_PID"

echo ""
echo "✅ Services started successfully!"
echo "📡 Backend API: http://localhost:8000"
echo "🎨 Frontend: http://localhost:3000"
echo "📊 Phoenix Tracing: https://app.phoenix.arize.com/"
echo ""
echo "Press Ctrl+C to stop all services"

# Function to cleanup when script is interrupted
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    echo "Services stopped."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Wait for services
wait
