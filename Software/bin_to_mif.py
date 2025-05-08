import sys

# Default settings
width = 8  # Width of each memory entry in bits (default 8 bits)
depth = None  # Depth will be calculated based on the binary file size

# Get input and output file paths from the command-line arguments
if len(sys.argv) < 3:
    print("Usage: python bin_to_mif.py <input_bin_file> <output_mif_file> [width] [depth]")
    sys.exit(1)

bin_file_path = sys.argv[1]
mif_file_path = sys.argv[2]

# Optional parameters for width and depth
if len(sys.argv) > 3:
    width = int(sys.argv[3])

if len(sys.argv) > 4:
    depth = int(sys.argv[4])

# Open the binary file in read mode
with open(bin_file_path, "rb") as bin_file:
    bin_data = bin_file.read()

# Calculate depth if not provided
if depth is None:
    depth = len(bin_data) // (width // 8)

# Open the MIF file for writing
with open(mif_file_path, "w") as mif_file:
    # Write the MIF header
    mif_file.write(f"DEPTH = {depth};\n")
    mif_file.write(f"WIDTH = {width};\n")
    mif_file.write("ADDRESS_RADIX = DEC;\n")
    mif_file.write("DATA_RADIX = BIN;\n")
    mif_file.write("CONTENT BEGIN\n")
    
    # Write the memory content in the MIF format
    byte_index = 0
    for address in range(depth):
        # Get the current byte(s) in the appropriate width
        if byte_index < len(bin_data):
            memory_value = bin_data[byte_index:byte_index + (width // 8)]
            # Convert the byte(s) to a binary string, left-padded with zeros
            binary_value = ''.join(f"{byte:08b}" for byte in memory_value).ljust(width, '0')
            mif_file.write(f"    {address} : {binary_value};\n")
            byte_index += len(memory_value)
        else:
            mif_file.write(f"    {address} : {'0' * width};\n")
    
    mif_file.write("END;\n")

print(f"Conversion complete: {bin_file_path} -> {mif_file_path}")
