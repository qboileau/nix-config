#!/usr/bin/env bash

input_file="/tmp/screenshot.png"  # Replace with your input image file path
output_file="/tmp/screenshotblur.png"  # Replace with your desired output file path

rm -f $input_file $output_file

scrot $input_file

# Get the original dimensions of the image
original_dimensions=$(identify -format "%wx%h" "$input_file")

# Resize the image to a smaller resolution for faster processing
small_resolution_file="small_resolution.jpg"
time magick "$input_file" -filter Lanczos -resize 25% "$small_resolution_file"

# Apply Gaussian blur effect to the resized image
blurred_file="blurred.jpg"
time magick "$small_resolution_file" -blur 0x8 "$blurred_file"

# Resize the blurred image back to its original resolution
time magick "$blurred_file" -filter Lanczos -resize "$original_dimensions" "$output_file"

# Clean up intermediate files
rm "$small_resolution_file" "$blurred_file"


i3lock -i $output_file
