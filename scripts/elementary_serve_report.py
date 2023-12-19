#!/usr/bin/env python3

from flask import Flask, send_file
from azure.storage.blob import BlobClient
from datetime import datetime, timedelta
from flask_caching import Cache
from io import BytesIO
import os

app = Flask(__name__)

# Flask-Caching configuration
cache = Cache(app, config={'CACHE_TYPE': 'simple'})

# Replace these values with your actual Azure Storage Account details
account_name = os.environ["AZ_ACCOUNT_NAME"]
account_key = os.environ["AZ_ACCOUNT_KEY"]
container_name = os.environ["AZ_CONTAINER_NAME"]
blob_name = os.environ["AZ_BLOB_NAME"]

@app.route('/', methods=['GET'])
@cache.cached(timeout=300)  # Cache timeout is set to 300 seconds (5 minutes)
def download_file():
    try:
        # Replace 'your_blob_name' with the actual blob name you want to download
        blob_url = f"https://{account_name}.blob.core.windows.net"

        # Check if the file is in the cache
        cached_data = cache.get(blob_name)
        if cached_data:
            return send_file(BytesIO(cached_data), as_attachment=True, download_name=blob_name)

        # Download the blob content using account name and key
        blob_client = BlobClient(account_url=blob_url, container_name=container_name, blob_name=blob_name, credential=account_key)
        blob_data = blob_client.download_blob()

        file_content = blob_data.readall()

        # Store the file content in the cache
        cache.set(blob_name, file_content, timeout=300)  # Cache timeout is set to 300 seconds (5 minutes)

        # Send the file in the response
        return send_file(BytesIO(file_content), as_attachment=False, download_name=blob_name)

    except Exception as e:
        return f"An error occurred: {str(e)}"

if __name__ == '__main__':
    app.run(debug=True, port=int(os.getenv("ELEMENTARY_SERVE_PORT", "8080")))
