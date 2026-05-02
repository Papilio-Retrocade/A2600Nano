# A2600Nano on Papilio Retrocade

Complete setup guide for running A2600Nano (Atari 2600 VCS) on the Papilio Retrocade board.

---

## Hardware Requirements

### Required Components
- **Papilio Retrocade board** (v1.3 or v1.4)
  - Tang Primer 20K module (GW2A-18 FPGA)
  - ESP32-S3 SuperMini companion controller
  - Retrocade daughterboard with HDMI, SD card, and power
- **MicroSD card** - FAT32 formatted, 2GB-32GB recommended
- **HDMI display** - 720p or 1080p capable monitor/TV
- **USB-C cable** - For FPGA programming and ESP32 flashing
- **Power supply** - USB-C 5V, 1A minimum

### Optional Components
- **USB keyboard** - For menu navigation and configuration
- **USB gamepad** - For gameplay (connected via ESP32-S3)
- **Atari 2600 ROM files** - Legally obtained game dumps (.a26, .bin formats)

---

## Quick Start Checklist

- [ ] Flash FPGA-Companion firmware to ESP32-S3
- [ ] Build and program A2600Nano bitstream to FPGA
- [ ] Format SD card as FAT32
- [ ] Copy ROM files to SD card
- [ ] Power on and test

---

## Step 1: ESP32-S3 Firmware Setup

The ESP32-S3 SuperMini runs FPGA-Companion firmware to handle USB HID devices, SD card filesystem, and OSD menu.

### Download FPGA-Companion Firmware

**Repository:** https://github.com/GadgetFactory/FPGA-Companion (GadgetFactory fork with flash loading support)
**Upstream:** https://github.com/harbaum/FPGA-Companion
**Target:** ESP32-S2/S3

**Key Enhancement:** The GadgetFactory fork adds the ability to load FPGA bitfiles to flash from the `/cores/` directory on the SD card, allowing easy core switching without rebuilding.

**Pre-built firmware:**
1. Go to https://github.com/GadgetFactory/FPGA-Companion/releases
2. Download latest `firmware.bin` for ESP32-S3
3. **OR** download MiSTeryNano firmware: https://github.com/harbaum/MiSTeryNano/tree/main/firmware/misterynano_fw

### Flash Firmware to ESP32-S3

#### Windows (esptool)

```powershell
# Install esptool
pip install esptool

# Erase flash
esptool.py --chip esp32s3 --port COM3 erase_flash

# Flash firmware
esptool.py --chip esp32s3 --port COM3 --baud 921600 write_flash 0x0 firmware.bin
```

**Note:** Replace `COM3` with your actual COM port (check Device Manager).

#### Alternative: Use Arduino IDE

1. Install ESP32 board support in Arduino IDE
2. Select **ESP32S3 Dev Module** as board
3. Select correct COM port
4. Upload pre-compiled firmware via **Sketch → Upload Using Programmer**

### Verify ESP32 is Working

After flashing:
1. ESP32 should enumerate as USB device when powered
2. LED on ESP32-S3 SuperMini should blink during boot
3. Check serial monitor at 115200 baud for debug output

---

## Step 2: Build FPGA Bitstream

### Prerequisites

- **Gowin EDA** installed (v1.9.9 or later recommended)
  - Download: https://www.gowinsemi.com/en/support/download_eda/
  - Register for free education/hobbyist license

### Build Options

#### Option A: Gowin IDE (Graphical)

1. Open Gowin FPGA Designer
2. **File → Open Project** → Select `a2600nano_tp20k.gprj`
3. Verify project settings:
   - Device: **GW2A-LV18PG256C8/I7**
   - Package: **PBGA256**
   - Speed: **C8/I7**
4. **Process → Run All** (Synthesize + Place & Route)
5. Wait for completion (~5-10 minutes)
6. Output: `impl/pnr/a2600nano_tp20k.fs` bitstream file

#### Option B: Command Line (TCL Script)

```powershell
# From project root directory
cd c:\Users\jackg\OneDrive\GadgetFactory_Engineering\2024\papilio-labs\A2600Nano

# Run Gowin synthesis via TCL
gw_sh build_tp20k.tcl
```

### Verify Synthesis Success

Check for:
- **No errors** in synthesis report
- **Timing met** in Place & Route report
- **Resource utilization** < 90% LUTs

Open `impl/pnr/a2600nano_tp20k.rpt.html` to review full report.

---

## Step 3: Program FPGA

### Using Gowin Programmer

1. Connect USB-C cable to Retrocade board
2. Power on board
3. Open **Gowin Programmer**
4. Click **Scan Device** or **Cable Setup**
   - Select **Embedded USB JTAG**
   - Click **Query/Detect** to find FPGA
5. Device should show: **GW2AR-LV18QN88C8/I7** or **GW2A-LV18PG256C8/I7**
6. **Add** bitstream file:
   - File: `impl/pnr/a2600nano_tp20k.fs`
   - Operation: **exFlash Erase, Program thru GAO-Bridge**
   - Device: **GW2AR-18C** or **GW2A-18**
7. Click **Program/Configure**
8. Wait for completion (~30-60 seconds)
9. **Status: Success** should appear

### Verify Programming

- HDMI output should show A2600Nano boot screen or menu
- If blank screen, check HDMI cable and display compatibility
- ESP32 serial output should show SPI communication with FPGA

---

## Step 4: Prepare SD Card

### Format SD Card

**Requirements:**
- **File system:** FAT32 (not exFAT or NTFS)
- **Allocation unit size:** 32KB recommended (default is fine)
- **Size:** 2GB to 32GB (larger cards may not be FAT32 compatible)

#### Windows Format

```powershell
# Using diskpart (run as Administrator)
diskpart
list disk
select disk X    # Replace X with SD card disk number
clean
create partition primary
format fs=fat32 quick
assign
exit
```

#### Windows GUI

1. Right-click SD card drive in Explorer
2. **Format...**
3. File system: **FAT32**
4. Allocation unit size: **32768 bytes** or **Default**
5. Click **Start**

### Create Directory Structure

```
SD:\
├── a2600/              # ROM files go here
│   ├── Adventure.bin
│   ├── Pitfall.a26
│   └── ...
└── (optional other cores)
```

### Copy ROM Files

1. Obtain legal Atari 2600 ROM files (.a26 or .bin format)
2. Copy to `SD:\a2600\` folder
3. ROM filenames should be descriptive (shown in menu)

**ROM Sources (Legal):**
- Homebrew games: https://atariage.com/forums/forum/65-atari-2600-homebrew/
- Public domain ROMs
- **Do NOT pirate commercial ROMs** - obtain legally only

### Test SD Card

1. Safely eject SD card from PC
2. Insert into Retrocade SD slot
3. Power on Retrocade
4. Menu should display ROM list

---

## Step 5: First Boot and Usage

### Power On Sequence

1. Insert programmed SD card
2. Connect HDMI cable to display
3. Connect USB keyboard (via ESP32-S3)
4. Connect USB-C power
5. Board should boot within 2-3 seconds

### Expected Boot Behavior

1. **HDMI sync** - Display recognizes signal
2. **A2600Nano menu** appears on screen
3. **ROM list** from SD card displays
4. **ESP32 activity** - LED blinks during SD card access

### Menu Navigation

**Keyboard Controls (via USB):**
- **Arrow Keys** - Navigate menu
- **Enter** - Select ROM
- **Esc** - Return to menu from game
- **F12** - Open OSD settings (if implemented)

**USB Gamepad:**
- **D-Pad** - Navigate menu
- **A/B button** - Select
- **Start** - Launch ROM

### Load and Play a ROM

1. Navigate to desired game in menu
2. Press **Enter** or gamepad **A button**
3. ROM loads (2-5 seconds)
4. Game starts
5. Play using keyboard or gamepad

### Atari 2600 Game Controls

**Keyboard Mapping:**
- **Arrow Keys** - Joystick direction
- **Ctrl** - Fire button
- **F1** - Reset
- **F2** - Select
- **F3** - B&W / Color switch

**USB Gamepad:**
- **Left Stick / D-Pad** - Joystick direction
- **A button** - Fire
- **Start** - Reset
- **Select** - Select switch

---

## Troubleshooting

### No HDMI Output

**Check:**
- [ ] HDMI cable connected firmly
- [ ] Display set to correct HDMI input
- [ ] FPGA programmed successfully (verify in Gowin Programmer log)
- [ ] Bitstream file matches device (GW2A-18)

**Try:**
- Different HDMI cable
- Different display/TV
- Re-program FPGA bitstream

### SD Card Not Detected

**Check:**
- [ ] SD card formatted as FAT32 (not exFAT)
- [ ] SD card inserted fully with contacts facing correct direction
- [ ] ESP32 firmware flashed and running
- [ ] `a2600/` folder exists on SD card

**Try:**
- Re-format SD card as FAT32
- Try smaller SD card (2GB-8GB more reliable)
- Check ESP32 serial output for filesystem errors

### ESP32 Not Responding

**Check:**
- [ ] ESP32-S3 SuperMini seated properly
- [ ] Firmware flashed to address 0x0
- [ ] USB enumeration in Device Manager (Windows)

**Try:**
- Erase ESP32 flash completely and re-flash
- Check serial output at 115200 baud
- Verify SPI pins connected correctly between ESP32 and FPGA

### ROM Won't Load

**Check:**
- [ ] ROM file format is .a26 or .bin
- [ ] ROM file not corrupted (verify file size > 0)
- [ ] ROM compatible with Atari 2600 (not 5200, 7800, etc.)

**Try:**
- Different ROM file
- Re-download ROM from known-good source
- Check for ROM size limits (most 2600 ROMs are 2KB-16KB)

### No Audio

**Note:** Audio output is via **HDMI only** on Retrocade.

**Check:**
- [ ] Display/TV HDMI audio enabled
- [ ] Volume not muted on display
- [ ] Correct HDMI input selected

**Try:**
- Test with different game (some ROMs have no sound)
- Check HDMI audio settings in TV menu

### Gamepad Not Working

**Check:**
- [ ] USB gamepad connected to ESP32-S3 USB host
- [ ] FPGA-Companion firmware supports gamepad (check compatibility)
- [ ] Gamepad is HID-compliant (DirectInput or XInput)

**Try:**
- USB keyboard instead (known to work)
- Different USB gamepad
- Check ESP32 serial output for HID enumeration

---

## Performance and Compatibility

### FPGA Resource Usage

- **LUTs:** ~60-70% of GW2A-18 capacity
- **BSRAM:** Moderate usage
- **Timing:** Meets 27 MHz clock requirements

### ROM Compatibility

**Supported:**
- Standard Atari 2600 cartridges (2K-16K)
- Superchip games (additional RAM)
- Most homebrew titles

**Auto-detection:**
- Cartridge type (ROM mapper)
- NTSC vs PAL region
- Superchip RAM presence

**Not Supported:**
- Atari 5200/7800 ROMs (different system)
- Special cartridges requiring hardware (SaveKey, AtariVox)

### Video Output

- **NTSC mode:** 768x480p @ 60Hz
- **PAL mode:** 768x576p @ 50Hz
- **Auto-detected** from ROM region

---

## Advanced Configuration

### Changing Video Mode

Video mode is typically auto-detected. If you need to force NTSC or PAL:

1. Check if OSD menu has video mode option (F12 key)
2. Modify VHDL source and rebuild (advanced)

### Custom FPGA Builds

To modify the core:

1. Edit VHDL source files in `src/`
2. Modify pin assignments in `src/a2600_top_tp20k.cst` (Retrocade pins)
3. Rebuild using Gowin IDE or TCL script
4. Re-program FPGA

### ESP32 Firmware Customization

FPGA-Companion firmware source:
- GadgetFactory fork: https://github.com/GadgetFactory/FPGA-Companion (with flash loading)
- Upstream: https://github.com/harbaum/FPGA-Companion
- Build using PlatformIO or Arduino IDE
- Customize USB HID mappings, OSD menu, file browser

---

## Technical Details

### Retrocade Pin Mapping

**HDMI Differential Pairs:**
- TMDS D0: M6 (P), T8 (N)
- TMDS D1: T11 (P), P11 (N)
- TMDS D2: T12 (P), R11 (N)
- TMDS CLK: P6 (P), T6 (N)

**ESP32-S3 SPI Interface:**
- CS (m0s[2]): A12
- CLK (m0s[3]): A11
- MOSI (m0s[0]): J11
- MISO (m0s[1]): B11
- IRQ (m0s[4]): C11
- Flash CS (m0s[5]): F10

**SD Card (Shared Tang Primer 20K pins):**
- CLK: N10
- CMD: R14
- DAT0: M8
- DAT1: M7
- DAT2: M10
- DAT3: N11

**Clock:**
- 27 MHz: H11

### SPI Communication Protocol

A2600Nano uses the MiSTeryNano SPI protocol for FPGA ↔ ESP32 communication:

- **Documentation:** https://github.com/harbaum/MiSTeryNano/blob/main/SPI.md
- **Functions:** USB HID input, SD card access, OSD rendering, ROM loading
- **SPI Mode:** Mode 0 (CPOL=0, CPHA=0)
- **Clock:** Up to 20 MHz

---

## References and Resources

### Upstream Projects

- **A2600Nano (MiSTle-Dev):** https://github.com/MiSTle-Dev/A2600Nano
- **MiSTeryNano (Till Harbaum):** https://github.com/harbaum/MiSTeryNano
- **FPGA-Companion (GadgetFactory):** https://github.com/GadgetFactory/FPGA-Companion (fork with flash loading)
- **FPGA-Companion (upstream):** https://github.com/harbaum/FPGA-Companion
- **Original A2600 core (Retromaster):** https://retromaster.wordpress.com/a2601/

### Papilio Retrocade

- **Retrocade Fork:** https://github.com/Papilio-Retrocade/A2600Nano
- **Branch:** `retrocade`
- **Project Documentation:** `c:\development\papilio-works\retrocade-hardware\arcade-projects\projects\a2600nano.md`

### Atari 2600 Resources

- **AtariAge Forums:** https://atariage.com/forums/
- **Homebrew Games:** https://atariage.com/forums/forum/65-atari-2600-homebrew/
- **Technical Documentation:** https://problemkaputt.de/2k6specs.htm

---

## Support and Contributions

### Getting Help

1. Check this README troubleshooting section
2. Review Papilio Retrocade documentation
3. Check upstream A2600Nano issues: https://github.com/MiSTle-Dev/A2600Nano/issues
4. Check FPGA-Companion issues:
   - GadgetFactory fork: https://github.com/GadgetFactory/FPGA-Companion/issues
   - Upstream: https://github.com/harbaum/FPGA-Companion/issues

### Reporting Issues

If you encounter Retrocade-specific issues:

1. Test on upstream Tang Primer 20K (if available) to isolate Retrocade-specific bugs
2. Open issue at: https://github.com/Papilio-Retrocade/A2600Nano/issues
3. Include:
   - Retrocade board version (v1.3, v1.4)
   - FPGA bitstream build date
   - ESP32 firmware version
   - Steps to reproduce
   - Serial output from ESP32 (if applicable)

### Contributing

Contributions welcome! Areas for improvement:

- [ ] Paddle controller support
- [ ] Additional cartridge mapper support
- [ ] Better OSD menu integration
- [ ] Save state functionality
- [ ] Custom Retrocade features (RGB LED integration, etc.)

---

## License

A2600Nano core and this Retrocade port follow the original project licenses:

- **A2600 core:** Original license by Retromaster
- **MiSTeryNano/FPGA-Companion:** Till Harbaum's license
- **Retrocade modifications:** MIT License (Papilio Works)

See upstream repositories for complete license information.

---

**Last Updated:** May 2, 2026  
**Retrocade Version:** v1.0 (branch: `retrocade`)  
**Tested On:** Papilio Retrocade v1.3 (hardware validation pending)

---

## Changelog

### v1.0-retrocade (May 2, 2026)
- Initial Retrocade port from MiSTle-Dev/A2600Nano
- HDMI pin mappings for Retrocade board
- ESP32-S3 SuperMini SPI interface
- Removed Tang Dock PMOD dependencies (DualShock, digital joystick, LEDs)
- All HID via FPGA-Companion firmware
