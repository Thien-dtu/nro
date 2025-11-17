#!/usr/bin/env python3

"""

NRO Offline Server Setup Script - DEOBFUSCATED VERSION

This is the readable version of nro.py for security review.

 

Original obfuscated version has been decoded for transparency.

"""

 

import requests

from tqdm import tqdm

import subprocess

import pymysql

import zipfile

import os

 

# Download URLs (these were obfuscated in original)

SERVER_ZIP_URL = 'https://github.com/NGUYENTRIEUPHUC/nro-offline/releases/download/SOURCE/NRO.OFFLINE.zip'

SQL_FILE_URL = 'https://github.com/NGUYENTRIEUPHUC/nro-offline/releases/download/SOURCE/solomon.1.sql'

 

 

def download_file(url, filename):

    """

    Downloads a file from URL with progress bar.

 

    Args:

        url: URL to download from

        filename: Local filename to save to

    """

    response = requests.get(url, stream=True)

    response.raise_for_status()

 

    with open(filename, 'wb') as f:

        for chunk in tqdm(response.iter_content(1024), desc='Downloading', unit='KB'):

            f.write(chunk)

 

 

def extract_zip(zip_file, extract_to):

    """

    Extracts a ZIP file.

 

    Args:

        zip_file: Path to ZIP file

        extract_to: Directory to extract to

    """

    print('Extracting...')

    with zipfile.ZipFile(zip_file, 'r') as z:

        z.extractall(extract_to)

    print('Extraction complete!')

 

 

def start_server():

    """

    Starts the game server by running start.sh script.

    """

    start_script = 'NRO-Server/start.sh'

 

    if os.path.exists(start_script):

        print('Starting server...')

        subprocess.run(['bash', '-c', start_script])

    else:

        print(f"Error: {start_script} not found!")

 

 

def import_sql(sql_file, host, user, password, port):

    """

    Imports SQL file into MySQL database.

 

    Args:

        sql_file: Path to SQL file

        host: MySQL host

        user: MySQL username

        password: MySQL password

        port: MySQL port

    """

    try:

        # Connect to MySQL

        connection = pymysql.connect(

            host=host,

            user=user,

            password=password,

            port=port

        )

        print('Connected to MySQL database')

 

        cursor = connection.cursor()

 

        # Read and execute SQL file

        with open(sql_file, 'r', encoding='utf-8') as f:

            sql_content = f.read()

 

        # Execute each SQL statement (split by semicolon)

        for statement in sql_content.split(';'):

            if statement.strip():

                cursor.execute(statement)

 

        connection.commit()

        print('SQL import successful!')

 

    except Exception as e:

        print(f"Error during SQL import: {e}")

    finally:

        connection.close()

 

 

def show_menu():

    """

    Displays interactive menu for server setup.

    """

    while True:

        print('\n=== MENU ===')

        print('1. Download and install server')

        print('2. Download and import SQL')

        print('3. Start server')

        print('4. Exit')

 

        choice = input('Choose option: ')

 

        if choice == '1':

            # Download and install server files

            print('Downloading server files...')

            zip_filename = 'NRO.zip'

            download_file(SERVER_ZIP_URL, zip_filename)

 

            if os.path.exists(zip_filename):

                extract_dir = 'NRO-Server'

                os.makedirs(extract_dir, exist_ok=True)

                extract_zip(zip_filename, extract_dir)

 

        elif choice == '2':

            # Download and import SQL database

            print('Downloading SQL...')

            sql_filename = 'nro_offline.sql'

            download_file(SQL_FILE_URL, sql_filename)

            print(f"File SQL downloaded: {sql_filename}")

 

            # Get MySQL connection details from user

            host = input('Enter MySQL host (default: localhost): ') or 'localhost'

            user = input('Enter MySQL user: ')

            password = input('Enter MySQL password: ')

            port = input('Enter MySQL port (default: 3306): ') or '3306'

 

            import_sql(sql_filename, host, user, password, int(port))

 

        elif choice == '3':

            # Start the server

            start_server()

 

        elif choice == '4':

            # Exit program

            print('Exiting...')

            break

 

        else:

            print('Invalid option! Please choose 1-4.')

 

 

if __name__ == '__main__':

    show_menu()

 