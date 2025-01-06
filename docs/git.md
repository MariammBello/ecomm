# GitHub Setup Guide

This guide explains how to set up and verify GitHub SSH access for your development environment.

## 1. Generate SSH Key

```bash
# Generate a new SSH key (use your GitHub email)
ssh-keygen -t ed25519 -C "your-email@example.com"

# When prompted:
# - Press Enter to accept the default file location (~/.ssh/id_ed25519)
# - Enter a secure passphrase (recommended) or press Enter for no passphrase
```

## 2. Add SSH Key to SSH Agent

```bash
# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519
```

## 3. Add SSH Key to GitHub

```bash
# Display your public key
cat ~/.ssh/id_ed25519.pub
```

Then:
1. Copy the output (your public key)
2. Go to GitHub.com → Settings → SSH and GPG keys
3. Click "New SSH key"
4. Give it a descriptive title (e.g., "Development VM")
5. Paste your public key in the "Key" field
6. Click "Add SSH key"

## 4. Verify Connection

### Test SSH Connection
```bash
# Verify SSH connection to GitHub
ssh -T git@github.com

# Expected output:
# Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### Verify SSH Agent
```bash
# Check if your key is loaded in ssh-agent
ssh-add -l

# Should show your key's fingerprint
```

### Test Repository Access
```bash
# Create a test directory
mkdir test_github
cd test_github

# Try cloning your repository
git clone git@github.com:YourUsername/YourRepo.git
```

### Check Git Configuration
```bash
# View git configuration
git config --list | grep url

# Should show SSH URLs (git@github.com:...)
```

## 5. Troubleshooting

If you encounter issues:

### SSH Key Problems
```bash
# Check SSH key permissions
ls -l ~/.ssh/id_ed25519*

# Should show:
# id_ed25519: -rw------- (600)
# id_ed25519.pub: -rw-r--r-- (644)

# Fix permissions if needed
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Connection Issues
```bash
# Test SSH connection with verbose output
ssh -vT git@github.com

# Check SSH configuration
cat ~/.ssh/config
```

### Git Configuration
```bash
# Set up Git user information
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

## 6. Best Practices

1. **Always use SSH keys** instead of passwords
2. **Backup your SSH keys** securely
3. **Use different keys** for different machines
4. **Regularly review** your SSH keys in GitHub settings
5. **Remove old or unused keys** from GitHub

## 7. Additional Resources

- [GitHub's SSH Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [SSH Key Best Practices](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [GitHub Security Best Practices](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure)
