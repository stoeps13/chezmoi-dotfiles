#!/usr/bin/env python
"""
ServiceNow Configuration Module

This module provides functions for loading configuration for ServiceNow
from a .sn_envrc file in the user's home directory.
"""

import os
import sys
import pathlib

def load_config():
    """
    Load ServiceNow configuration from .sn_envrc file in home directory

    Returns:
        tuple: (username, password, base_url)

    Exits with error if credentials are not found.
    """
    home_dir = str(pathlib.Path.home())
    env_file = os.path.join(home_dir, '.sn_envrc')

    username = ''
    password = ''
    base_url = "https://support.hcl-software.com"  # Default value

    try:
        with open(env_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('SN_USERNAME='):
                    username = line[len('SN_USERNAME='):].strip('"\'')
                elif line.startswith('SN_PASSWORD='):
                    password = line[len('SN_PASSWORD='):].strip('"\'')
                elif line.startswith('SN_BASE_URL='):
                    base_url = line[len('SN_BASE_URL='):].strip('"\'')
    except FileNotFoundError:
        print(f"Error: Config file not found at {env_file}")
        print("Please create a .sn_envrc file in your home directory with the following format:")
        print("SN_USERNAME=your_username")
        print("SN_PASSWORD=your_password")
        print("SN_BASE_URL=https://support.hcl-software.com  # Optional")
        sys.exit(1)

    if not username or not password:
        print("Error: Username or password not found in .sn_envrc file")
        sys.exit(1)

    return username, password, base_url

def get_auth_basic():
    """
    Get HTTP Basic Auth object from ServiceNow configuration

    Returns:
        HTTPBasicAuth: Authentication object for requests
    """
    from requests.auth import HTTPBasicAuth
    username, password, _ = load_config()
    return HTTPBasicAuth(username, password)

def get_base_url():
    """
    Get base URL for ServiceNow instance

    Returns:
        str: Base URL for ServiceNow instance
    """
    _, _, base_url = load_config()
    return base_url

if __name__ == "__main__":
    # If this script is run directly, print the configuration
    username, _, base_url = load_config()
    print(f"Successfully loaded configuration for {username} at {base_url}")
