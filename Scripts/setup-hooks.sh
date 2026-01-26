#!/bin/sh

# Install pre-commit hook
cp Scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "Git hooks installed successfully!"
