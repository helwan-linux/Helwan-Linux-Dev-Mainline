#!/bin/bash

# Program Description: Building Helwan Linux
# Developer: Saeed Badrelden [saeedbadrelden2021@gmail.com]
# OS Distribution: Helwan OS
# Distro Mail: helwanlinux@gmail.com
# Version: al-amal
# Date: 25 Mar 2025
# Website: https://helwan-linux.mystrikingly.com/
# Forum: https://helwanlinux.createaforum.com/index.php

set -e  # Exit on first error

# Colors
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

LOGFILE="helwan_build.log"

echo -e "${GREEN}🚀 Starting Helwan Linux build...${NC}"
echo "" 

# Run build and save logs
if sudo mkarchiso -v "." | tee "$LOGFILE"; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
else
    echo -e "${RED}❌ Build failed.${NC}"
    echo ""
    echo "🔍 Last 20 log lines:"
    tail -n 20 "$LOGFILE"
    echo ""
    echo "📄 Full log saved to: $LOGFILE"
    exit 1
fi

echo ""
echo -e "${GREEN}🏁 Build process finished.${NC}"
