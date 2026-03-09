#!/bin/bash
# Jasypt Encryption Helper Script
# Usage: ./encrypt-credentials.sh <value_to_encrypt> <encryption_key>

if [ $# -eq 0 ]; then
    echo "Jasypt Encryption Helper"
    echo "Usage: $0 <value_to_encrypt> <encryption_key>"
    echo ""
    echo "Examples:"
    echo "  $0 postgres MySecretPassword123"
    echo "  $0 SecurePassword123! MySecretPassword123"
    echo ""
    echo "Or use interactively:"
    echo "  $0"
    exit 1
fi

# Check if jasypt is installed
if ! command -v jasypt &> /dev/null; then
    echo "ERROR: jasypt not found in PATH"
    echo ""
    echo "Install jasypt:"
    echo "  macOS: brew install jasypt"
    echo "  Linux: Download from https://github.com/ulisesbocchio/jasypt-spring-boot/releases"
    echo "  Or download and use Maven directly"
    exit 1
fi

VALUE=$1
KEY=$2

if [ -z "$VALUE" ] || [ -z "$KEY" ]; then
    echo "Interactive mode:"
    read -p "Enter value to encrypt: " VALUE
    read -sp "Enter encryption key: " KEY
    echo ""
fi

echo ""
echo "Encrypting value with Jasypt..."
echo "Value: $VALUE"
echo "Key: (hidden for security)"
echo ""

# Encrypt using Jasypt
ENCRYPTED=$(jasypt encrypt input="$VALUE" password="$KEY" algorithm=PBEWITHHMACSHA512ANDAES_256)

if [ $? -eq 0 ]; then
    echo "✓ Encryption successful!"
    echo ""
    echo "Use this in your application.properties:"
    echo "spring.datasource.password=ENC($ENCRYPTED)"
    echo ""
    echo "Or for other properties:"
    echo "some.property=ENC($ENCRYPTED)"
    echo ""
    echo "Then run application with:"
    echo "export JASYPT_ENCRYPTOR_PASSWORD=\"$KEY\""
    echo "java -jar service-1.0.0.jar"
    echo ""
    echo "For Docker Compose:"
    echo "environment:"
    echo "  JASYPT_ENCRYPTOR_PASSWORD: \"$KEY\""
    echo "  SPRING_DATASOURCE_PASSWORD: ENC($ENCRYPTED)"
else
    echo "✗ Encryption failed!"
    echo "Make sure jasypt is installed and the value is valid"
    exit 1
fi
