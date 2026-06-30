import os
import zipfile

def zip_directory(folder_path, zip_path):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                # Compute relative path and force forward slashes for Linux compatibility
                relative_path = os.path.relpath(file_path, folder_path)
                relative_path = relative_path.replace('\\', '/')
                zipf.write(file_path, relative_path)
                print(f"Added: {relative_path}")

folder_to_zip = "C:/xampp/htdocs/lucky_spin_backend"
output_zip = "C:/xampp/htdocs/spin/lucky_spin_backend.zip"

if os.path.exists(output_zip):
    os.remove(output_zip)

zip_directory(folder_to_zip, output_zip)
print("ZIP regenerated successfully with Linux compatible paths!")
