#include <assert.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

// References used:
// javascrip internals of https://tomverbeure.github.io/video_timings_calculator (thanks Clever for sending it)
// https://en.wikipedia.org/wiki/Extended_Display_Identification_Data 
// and some other references i dont remember since it was 3AM when i did this. (this is not recommended for your health or sanity... dont do this)
//
// AI as only been used to make a summary/explanation of how the EDID format works, and to find working reduced blanking constants.



// VESA CVT Reduced Blanking struct.
// Takes horizontal/vertical resolution and refresh rate and computes
// pixel_clock, hfp, hsync, hbp, vfp, vsync, vbp

struct cvt_mode {
  uint32_t pixel_clock;
  uint16_t hfp;
  uint16_t hsync;
  uint16_t hbp;
  uint16_t vfp;
  uint16_t vsync;
  uint16_t vbp;
};


struct cvt_mode cvt_reduced_blank(int hdisplay, int vdisplay, int vrefresh) {
  // some CVT-RB constants, works goods enough
  const int RB_H_BLANK  = 160;      // fixed horizontal blanking pixels
  const int RB_H_SYNC   = 32;       // fixed horizontal sync width pixels
  const int RB_VFP      = 3;        // fixed vertical front porch lines
  const int RB_MIN_VBLANK_US = 460; // minimum vertical blanking time (us)
  const int MIN_V_BPORCH = 6;       // minimum vertical back porch lines
  const int H_GRAN       = 8;       // character cell horizontal granularity
  const int CLOCK_STEP   = 250;     // pixel clock rounding step (kHz)

  // Determine vsync width from aspect ratio
  int vsync;
  if (vdisplay != 0 && !(vdisplay % 3) && (vdisplay * 4 / 3 == hdisplay))
    vsync = 4;    // 4:3
  else if (vdisplay != 0 && !(vdisplay % 9) && (vdisplay * 16 / 9 == hdisplay))
    vsync = 5;    // 16:9
  else if (vdisplay != 0 && !(vdisplay % 10) && (vdisplay * 16 / 10 == hdisplay))
    vsync = 6;    // 16:10
  else if (vdisplay != 0 && !(vdisplay % 4) && (vdisplay * 5 / 4 == hdisplay))
    vsync = 7;    // 5:4
  else if (vdisplay != 0 && !(vdisplay % 9) && (vdisplay * 15 / 9 == hdisplay))
    vsync = 7;    // 15:9
  else
    vsync = 10;   // custom or unknown aspect

  // Round Hdisplay to character cell boundary
  int hdisplay_rnd = hdisplay - (hdisplay % H_GRAN);

  // Estimate horizontal period (in units of 1/1000 pixel clock)
  int64_t tmp1 = (int64_t)1000 * 1000000 - (int64_t)RB_MIN_VBLANK_US * 1000 * vrefresh;
  int64_t tmp2 = vdisplay;
  int hperiod = tmp1 / (tmp2 * vrefresh);

  // Find number of lines in vertical blanking
  int vbilines = RB_MIN_VBLANK_US * 1000 / hperiod + 1;

  // Limit mininum vertical blanking
  if (vbilines < (RB_VFP + vsync + MIN_V_BPORCH))
    vbilines = RB_VFP + vsync + MIN_V_BPORCH;

  // Vertical totals
  int vtotal = vdisplay + vbilines;
  int vfp = RB_VFP;
  int vbp = vbilines - RB_VFP - vsync;

  // Horizontal totals
  int htotal = hdisplay_rnd + RB_H_BLANK;

  // Split horizontal blanking into front porch, sync, back porch
  int hsync_start = hdisplay_rnd + RB_H_BLANK / 2 - RB_H_SYNC;
  int hfp = hsync_start - hdisplay_rnd;
  int hsync = RB_H_SYNC;
  int hbp = htotal - hdisplay_rnd - hfp - hsync;

  // Compute pixel clock (kHz), rounded to CLOCK_STEP
  int64_t pclk_khz = (int64_t)htotal * 1000000 / hperiod;
  pclk_khz -= pclk_khz % CLOCK_STEP;

  // Convert to Hz and print the data
  uint32_t pixel_clock_hz = (uint32_t)(pclk_khz * 1000);
  printf("resolution: %dx%d @ %d Hz\n", hdisplay, vdisplay, vrefresh);
  printf("vsync width: %d (aspect ratio based)\n", vsync);
  printf("htotal: %d  vtotal: %d\n", htotal, vtotal);
  printf("hfp: %d  hsync: %d  hbp: %d\n", hfp, hsync, hbp);
  printf("vfp: %d  vsync: %d  vbp: %d\n", vfp, vsync, vbp);
  printf("pixel clock: %u Hz (%.2f MHz)\n", pixel_clock_hz, pixel_clock_hz / 1e6);
  printf("hfreq: %.2f kHz  vfreq: %.2f Hz\n", (float)pixel_clock_hz / (float)htotal / 1000.0, (float)pixel_clock_hz / (float)((int64_t)htotal * vtotal));

  // Populate struct with generated values and return ir
  struct cvt_mode mode = {
    .pixel_clock = pixel_clock_hz,
    .hfp  = (uint16_t)hfp,
    .hsync = (uint16_t)hsync,
    .hbp  = (uint16_t)hbp,
    .vfp  = (uint16_t)vfp,
    .vsync = (uint16_t)vsync,
    .vbp  = (uint16_t)vbp,
  };
  return mode;
}

// Generate EDID 1.4 Detailed Timing Descriptor data
// encode the DTD bytes per the VESA EDID standard (see Wikipedia link at top of file)
void add_detailed(uint8_t *buf, uint32_t pixel_clock,
  uint16_t hactive, uint16_t hfp, uint16_t hsync, uint16_t hbp,
  uint16_t vactive, uint16_t vfp, uint16_t vsync, uint16_t vbp,
  bool interlaced = false) {
  uint16_t hblank = hfp + hsync + hbp;
  uint16_t vblank = vfp + vsync + vbp;

  // Pixel clock in 10kHz units (EDID spec: bytes 0-1, little-endian)
  uint32_t pclk_10khz = pixel_clock / (10 * 1000);
  buf[0] = pclk_10khz & 0xff;
  buf[1] = pclk_10khz >> 8;

  // Horizontal active (8 lsbits)
  buf[2] = hactive & 0xff;
  // Horizontal blanking (8 lsbits)
  buf[3] = hblank & 0xff;
  // H active msbits (4) | H blanking msbits (4)
  buf[4] = (((hactive >> 8) & 0xf) << 4) | ((hblank >> 8) & 0xf);

  // Vertical active (8 lsbits)
  buf[5] = vactive & 0xff;
  // Vertical blanking (8 lsbits)
  buf[6] = vblank & 0xff;
  // V active msbits (4) | V blanking msbits (4)
  buf[7] = (((vactive >> 8) & 0xf) << 4) | ((vblank >> 8) & 0xf);

  // Horizontal front porch (8 lsbits)
  buf[8] = hfp & 0xff;
  // Horizontal sync pulse width (8 lsbits)
  buf[9] = hsync & 0xff;
  // V front porch (4 lsbits) | V sync width (4 lsbits)
  buf[10] = ((vfp & 0xf) << 4) | (vsync & 0xf);
  // HFP msbits(2) | HSYNC msbits(2) | VFP msbits(2) | VSYNC msbits(2)
  buf[11] = (((hfp>>8)&3) << 6) | (((hsync>>8)&3) << 4) | (((vfp>>8)&3) << 2) | ((vsync>>8)&3);

  // Physical size in mm (40mm x 30mm - arbitrary for virtual display)
  buf[12] = 40;
  buf[13] = 30;
  buf[14] = 0;  // H size msbits | V size msbits
  buf[15] = 0;  // H border
  buf[16] = 0;  // V border

  // Features: non-interlaced, digital separate sync, +hsync -vsync
  buf[17] = (interlaced << 7) | (3 << 3) | (1 << 1) | (0 << 2);
}

int main(int argc, char **argv) {
  if (argc < 3 || argc > 4) {
    fprintf(stderr, "Usage: %s <width> <height> [refresh_rate]\n", argv[0]);
    fprintf(stderr, "  refresh_rate defaults to 60\n");
    return 1;
  }

  int hactive = atoi(argv[1]);
  int vactive = atoi(argv[2]);
  int refresh = (argc >= 4) ? atoi(argv[3]) : 60;

  if (hactive <= 0 || vactive <= 0 || refresh <= 0) {
    fprintf(stderr, "Error: all values must be positive integers\n");
    return 1;
  }

  // Compute CVT Reduced Blanking timings
  struct cvt_mode timing = cvt_reduced_blank(hactive, vactive, refresh);

  // Build 128-byte EDID base block
  uint8_t buffer[128];
  memset(buffer, 0, 128);

  // Bytes 0-7: EDID header
  buffer[0] = 0x00;
  buffer[1] = 0xff;
  buffer[2] = 0xff;
  buffer[3] = 0xff;
  buffer[4] = 0xff;
  buffer[5] = 0xff;
  buffer[6] = 0xff;
  buffer[7] = 0x00;

  // Bytes 8-9: Manufacturer ID (0 = unknown)
  buffer[8] = 0;
  buffer[9] = 0;

  // Bytes 10-11: Product code
  buffer[10] = 0;
  buffer[11] = 0;

  // Bytes 12-15: Serial number
  buffer[12] = 0;
  buffer[13] = 0;
  buffer[14] = 0;
  buffer[15] = 0;

  // Byte 16: Week of manufacture (0x10 = week 16)
  buffer[16] = 0x10;

  //Byte 17: Year of manufacture (2024 - 1990 = 34)
  buffer[17] = (2024 - 1990);

  // Byte 18: EDID version (1)
  buffer[18] = 1;
  // Byte 19: EDID revision (4 = EDID 1.4)
  buffer[19] = 4;

  // Byte 20: Video input - digital, 8 bits per color, DFP 1.x
  buffer[20] = (1<<7) | (2<<4) | 1;

  // Bytes 21-22: Screen size (0 = undefined for virtual display)
  buffer[21] = 0;
  buffer[22] = 0;

  // Byte 23: Gamma (0 = not defined)
  buffer[23] = 0;

  // Byte 24: Supported features - no DPMS, no sRGB, preferred timing is DTD
  buffer[24] = 0;

  // Bytes 25-34: Chromaticity (zeros = undefined)
  // Not used in this case since its for a VM

  // Bytes 35-37: Established timings (all zeros = none)
  // We have no real need for timings since its inside a VM

  // Bytes 38-53: Standard timings (01 01 = unused, 8 entries)
  for (int i = 0; i < 8; i++) {
    buffer[38 + (i*2)]   = 0x01;
    buffer[38 + (i*2)+1] = 0x01;
  }

  // Bytes 54-71: Detailed Timing Descriptor #1 (default timing)
  add_detailed(buffer + 54, timing.pixel_clock, hactive, timing.hfp, timing.hsync, timing.hbp, vactive, timing.vfp, timing.vsync, timing.vbp);

  // Bytes 72-89: Descriptor 2 - Monitor name
  buffer[72] = 0x00;
  buffer[73] = 0x00;
  buffer[74] = 0x00;
  buffer[75] = 0xFC;  // Monitor name descriptor type
  buffer[76] = 0x00;
  const char *name = "DUMMY-EDID";
  int namelen = strlen(name);
  for (int i = 0; i < namelen && i < 13; i++)
    buffer[77 + i] = name[i];
  for (int i = namelen; i < 13; i++)
    buffer[77 + i] = 0x20;  // pad with spaces
  buffer[77 + 13] = 0x0A;  // line feed terminator

  // Bytes 90-125: Descriptors 3 & 4 (unused, leavign as all zeros)

  // Byte 126: Number of extension blocks
  buffer[126] = 0;

  // Byte 127: Checksum (sum of all 128 bytes must equal 0 mod 256)
  uint8_t sum = 0;
  for (int i = 0; i < 127; i++)
    sum += buffer[i];
  buffer[127] = 256 - sum;

  // Write binary EDID blob
  int fd = open("test.bin", O_WRONLY | O_CREAT, 0755);
  assert(fd >= 0);
  int ret = write(fd, buffer, 128);
  assert(ret == 128);
  close(fd);

  return 0;
}





// Friendly note for Clever...
// FOR THE LOVE OF GOD ADD COMMENTS TO YOUR CODE DAMMIT.