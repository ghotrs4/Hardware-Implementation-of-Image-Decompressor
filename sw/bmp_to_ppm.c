/*
   Copyright by Adam Kinsman, Jason Thong and Nicola Nicolici
   Department of Electrical and Computer Engineering
   McMaster University
   Ontario, Canada
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// print the info for device independent bitmap (DIB) header
void print_DIB_header_info (int dib_header_size);

int main(int argc, char **argv) {
	int i, j, width, height;
	char input_filename[200], output_filename[200];
	unsigned char *r_image, *g_image, *b_image;
	FILE *file_ptr;

	//get input file name either from first command line argument or from the user interface (command prompt)
	if (argc<2) {
		printf("Enter the input file name including the .bmp extension: ");
		fscanf(stdin, "%s", input_filename);
	}
	else strcpy(input_filename, argv[1]);

	//open input file
	file_ptr = fopen(input_filename, "rb");
	if (file_ptr==NULL) {
		printf("Cannot open file %s for binary reading, exiting...\n", input_filename);
		exit(1);
	}
	else printf("Opened input file %s\n", input_filename);

	//get output file name either from second command line argument or from the user interface (command prompt)
	if (argc<3) {
		printf("Enter the output file name including the .ppm extension: ");
		fscanf(stdin, "%s", output_filename);
	}
	else strcpy(output_filename, argv[2]);

	//read file format (expected BM)
	char file_format[3];
	file_format[0] = fgetc(file_ptr);
	file_format[1] = fgetc(file_ptr);
	file_format[2] = '\0';
	printf("File format: %s\n", file_format);

	//read file size
	int file_size;
	file_size = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		file_size += fgetc(file_ptr) << i;
	printf("File size: %d\n", file_size);

	// skip four bytes
	for (i=0; i<4; i++)
		fgetc(file_ptr);

	//read array_offset
	int array_offset;
	array_offset = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		array_offset += fgetc(file_ptr) << i;
	printf("Array offset: %d\n", array_offset);

	//read DIB header size
	int dib_header_size;
	dib_header_size = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		dib_header_size += fgetc(file_ptr) << i;
	printf("DIB header size: %d\n", dib_header_size);

	if ((dib_header_size + 14) != array_offset) {
		printf("DIB header size: %d\n", dib_header_size);
		printf("Array offset: %d\n", array_offset);
		printf("The difference must be 14 ... exiting\n");
		exit(1);
	}

	print_DIB_header_info(dib_header_size);

	//read image width and height from bmp header
	width = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		width += fgetc(file_ptr) << i;
	printf("Image width: %d\n", width);
	height = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		height += fgetc(file_ptr) << i;
	printf("Image height: %d\n", height);
	if (height < 0) {
		printf("Negative image height field - expecting positive value ... exiting!\n");
		exit(1);
	}

	// read color plan
	int colour_plane;
	colour_plane = fgetc(file_ptr);
	colour_plane += fgetc(file_ptr) << 8;
	if (colour_plane != 1) {
		printf("The plane field is %d - it must be one ... exiting\n", colour_plane);
		exit(1);
	}

	// read bits per colour
	int bit_count;
	bit_count = fgetc(file_ptr);
	bit_count += fgetc(file_ptr) << 8;
	if (bit_count != 24) {
		printf("Bits per pixel is %d - we expect 24 bits (8 bits per colour) in the BMP file ... exiting\n", bit_count);
		exit(1);
	}

	// read compression mode
	int compression;
	compression = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		compression += fgetc(file_ptr) << i;
	if (compression != 0) {
		printf("Compression mode is %d - we expect this field to be zero (no compression) ... exiting\n", bit_count);
		exit(1);
	}

	// read image size
	int image_size;
	image_size = fgetc(file_ptr);
	for (i=8; i<=24; i+=8)
		image_size += fgetc(file_ptr) << i;
	printf("Image size: %d\n", image_size);

	int number_of_words_per_row = (width * 24 + 31)/ 32;
	int bytes_per_row = number_of_words_per_row * 4;
	if (bytes_per_row != 3 * width)
		printf("There are %d dummy bytes in each row\n", (bytes_per_row - 3 * width));

	if (image_size == 0) {
		printf("Warning: the image size field has been set to zero by the SW that produced the BMP file\n");
		printf("This is not critical - however the data might be corrupted (check your image visually)\n");
	} else if (image_size != bytes_per_row * height) {
		printf("Image size must be equal to width multiplied by height multiplied by number of bytes per pixel ... exiting\n");
		exit(1);
	}

	if ((bytes_per_row * height) != file_size - dib_header_size - 14) {
		printf("Bytes per row x number of rows must be equal to file size - total header size ... exiting\n");
		exit(1);
	}

	// skip the rest of the DIB header (subtract 24 because that's how many bytes have been read from the DIB header
	// (excluding the first 14 bytes) for file size and array offset
	for (i=0; i < dib_header_size-24; i++)
		fgetc(file_ptr);

	//buffer the entire image in memory because the output row order is different between bmp (backwards) and ppm (forwards)
	r_image = (unsigned char *)malloc(sizeof(unsigned char)*width*height);
	g_image = (unsigned char *)malloc(sizeof(unsigned char)*width*height);
	b_image = (unsigned char *)malloc(sizeof(unsigned char)*width*height);
	if (r_image==NULL || g_image==NULL || b_image==NULL) { printf("malloc failed :(\n)"); exit(1); }

	//read bmp image, when reading file sequentially, will get data for the bottom row first, go across this row, then go up a row, and so on...
	for (i=0; i<height; i++) {
		for (j=0; j<width; j++) {	//color order is BGR
			b_image[width*(height-1-i)+j] = fgetc(file_ptr);
			g_image[width*(height-1-i)+j] = fgetc(file_ptr);
			r_image[width*(height-1-i)+j] = fgetc(file_ptr);
		}
		// skip dummy bytes at the end of each row
		for (j = 0; j < (bytes_per_row - 3 * width); j++)
			fgetc(file_ptr);
	}

	if (fgetc(file_ptr)!=EOF) {
		printf("Unsupported format, please re-regenerate the BMP file using your software ... ");
		printf("Exiting\n");
		exit(1);
	}
	fclose(file_ptr);

	//open output file
	file_ptr = fopen(output_filename, "wb");
	if (file_ptr==NULL) {
		printf("Cannot open file %s for binary writing ... exiting\n", output_filename);
		exit(1);
	}
	else printf("Opened output file %s\n", output_filename);

	//write ppm header
	fprintf(file_ptr, "P6\n%d %d\n255\n", width, height);

	//write ppm image, pixel order is across first, then down, color order is RGB
	for (i=0; i<height; i++) for (j=0; j<width; j++) {
		fputc(r_image[width*i+j], file_ptr);
		fputc(g_image[width*i+j], file_ptr);
		fputc(b_image[width*i+j], file_ptr);
	}

	free(r_image);
	free(g_image);
	free(b_image);
	fclose(file_ptr);
	printf("Done converting BMP to PPM\n\n");
	return 0;
}

void print_DIB_header_info (int dib_header_size) {

	switch (dib_header_size) {
		case 12:
			printf("Header type: BITMAPCOREHEADER\n");
			break;

		case 40:
			printf("Header type: BITMAPINFOHEADER\n");
			break;

		case 52:
			printf("Header type: BITMAPV2INFOHEADER\n");
			break;

		case 56:
			printf("Header type: BITMAPV3INFOHEADER\n");
			break;

		case 64:
			printf("Header type: OS22XBITMAPHEADER\n");
			break;

		case 108:
			printf("Header type: BITMAPV4HEADER\n");
			break;

		case 124:
			printf("Header type: BITMAPV5HEADER\n");
			break;

		default:
			printf("Header type: UNKNOWN\n");
			printf("Exiting\n");
			exit(1);
			break;
	}
}