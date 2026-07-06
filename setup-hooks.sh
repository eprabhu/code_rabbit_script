#!/bin/bash
echo "Installing Git hooks..."
cp hooks/* .git/hooks/
chmod +x .git/hooks/*
echo "Hooks installed successfully!"
