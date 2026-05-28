	DATA SEGMENT PARA PUBLIC USE16 'DATA'
	ORG 0h
	ASSUME DS:NOTHING

	NUM_TO_CHAR_PREP X_VESA_MEM, X_VESA_MEM_STR
	NUM_TO_CHAR_PREP MAX_VESA_MODE, MAX_VESA_MODE_STR

start_data:

;-------------------------------------------------------------------------------

	retf

;-------------------------------------------------------------------------------

dos_message_01:
	DB	0Dh,'Invalid DOS version (5.0 or above)',0Dh,0Ah,'$'
dos_message_02:
	DB	0Dh,'Failed to detect 80386 or above processor',0Dh,0Ah,'$'
dos_message_03:
	DB	'X-VESA V',X_VESA_VERSION,' - VESA check utility by Marco Pistella',0Dh,0Ah,'$'
dos_message_04:
	DB	0Dh,'Invalid DOS environment',0Dh,0Ah,'$'
dos_message_05:
	DB	0Dh,'Path too deep',0Dh,0Ah,'$'
dos_message_06:
	DB	0Dh,'Error during DOS I/O',0Dh,0Ah,'$'
dos_message_07:
	DB	0Dh,'Don''t modify X-VESA.COM. Probably virus attack!',0Dh,0Ah,'$'
dos_message_08:
	DB	0Dh,'Don''t rename X-VESA.COM',0Dh,0Ah,'$'
dos_message_09:
	DB	0Dh,'Can''t set color text video mode',0Dh,0Ah,'$'
dos_message_10:
	DB	0Dh,'No VGA adapter detected',0Dh,0Ah,'$'
dos_message_11:
	DB      0Dh,'No VESA Standard present',0Dh,0Ah,'$'
dos_message_12:
	DB	0Dh,'Invalid VESA mode table',0Dh,0Ah,'$'
dos_message_13:
	DB	0Dh,'No VESA video modes or all VESA video modes are invalid',0Dh,0Ah,'$'
dos_message_14:
	DB	'Text mode video initialization failed',0Dh,0Ah,'$'
dos_message_15:
	DB	0Dh,0Ah,'Buggy VGA detected!',0Dh,0Ah,'Try to set the video mode via BIOS? [Y/N] $'
dos_message_16:
	DB	'Wait ...$'
dos_message_17:
	DB	0Dh,'Insufficient free conventional memory: ',X_VESA_MEM_STR,' Bytes or more required',0Dh,0Ah,'$'
dos_message_18:
	DB	0Dh,'80386 with mul bug detected',0Dh,0Ah,'$'

;-------------------------------------------------------------------------------

edid_message_01:
	DB	'EDID info',0h
edid_message_02:
	DB	'Monitor identifier',0h
edid_message_03:
	DB	'Monitor physical attributes',0h
edid_message_04:
	DB	'Monitor chromaticity',0h
edid_message_05:
	DB	'Supported video modes',0h
edid_message_06:
	DB	'Detailed timing video modes',0h
edid_message_07:
	DB	'Descriptor definitions (FF/FE/FD/FC)',0h
edid_message_08:
	DB	'Descriptor definitions (FB/FA/F9)',0h
edid_message_09:
	DB	'Descriptor definitions (F8/F7)',0h

;-------------------------------------------------------------------------------

vga_message_001:
	DB	'[F]=Fail, ',0h
vga_message_002:
	DB	'[R]=Retry, ',0h
vga_message_003:
	DB	'[I]=Ignore, ',0h
vga_message_004:
	DB	'Critical DOS handler',0h
vga_message_005:
	DB	'Extended error:',0F0h
	DB	'Error class:',0F0h
	DB	'Suggested action:',0F0h
	DB	'Location of error:',0h
vga_message_006:
	DB	'Help keys',0h
vga_message_007:
	DB	'[ESC]=Exit',0h
vga_message_008:
	DB	'[',18h,19h,', Home, End, PgUp, PgDn]=Navigate',0F0h
	DB	'[ENTER]=Select video mode',0F0h
	DB	'[ESC]=Exit',0F0h
	DB	'[F1]=This help',0F0h
	DB	'[F2]=Save screenshot (works everywhere)',0F0h
	DB	'[F6]=View VRAM size for each video mode',0F0h
	DB	'[F7]=Show VESA VBE/PM capabilities',0F0h
	DB	'[F8]=CPU capabilities',0F0h
	DB	'[F9]=Read EDID',0F0h
	DB	'[F10]=Extra adapter info',0h
vga_message_009:
	DB	'X-VESA V',X_VESA_VERSION,' - VESA diagnostic utility by Marco Pistella',0h
vga_message_010:
	DB	'[F1]=Help',0h
vga_message_011:
	DB	'Ñ',0F1h,7h,'Ñ',0F1h,7h,'Ñ',0F1h,7h,'Ñ',0F1h,9h,'Ñ',0F1h,9h,'Ñ',0F1h,0Ch,'Ñ',0F1h,0Dh,'»'
	DB	'º  Mode ³ X Res ³ Y Res ³ Bpp/M ³ Display ³ Segment ³ Window Len ³ Granularity º'
	DB	'Ç',0F3h,7h,'ÄÁ',0F3h,7h,'ÄÁ',0F3h,7h,'ÄÁ',0F3h,7h,'ÄÁ',0F3h,9h,'ÄÁ',0F3h,9h,'ÄÁ',0F3h,0Ch,'ÄÁ',0F3h,0Dh,'Ä¶',0h
vga_message_012:
	DB	'VESA Version:',0F2h
	DB	'OEM name:',0F2h
	DB	'Capabilities:',0F2h
	DB	'Video memory:',0h
vga_message_013:
	DB	0F4h,3h,COLOR_BASE,'KiB',0
vga_message_014:
	DB	'TEXT',0h
vga_message_015:
	DB	'GRAPHIC',0h
vga_message_016:
	DB	'CPU Capabilities',0h
vga_message_017:
	DB	'Virtual 8086 mode:',0F2h
	DB	'FPU Support:',0F2h
	DB	'A20 line enabled:',0F2h
	DB	'CPUID Support:',0F2h
	DB	'SSE Support:',0F2h
	DB	'AVX Support:',0F2h
	DB	'AVX/512F Support:',0h
vga_message_018:
	DB	0F4h,14h,ND_COLOR,'Undetectable in VM86',0h
vga_message_019:
	DB	'Adapter information',0h
vga_message_020:
	DB	0F4h,1Ah,ND_COLOR,'VESA 2.0 or above required',0h
vga_message_021:
	DB	'OEM Software revision:',0F2h
	DB	'Vendor name:',0F2h
	DB	'Product name:',0F2h
	DB	'Product revision:',0F2h
	DB	'Video BIOS ROM size:',0F2h
	DB	'PCI Vendor/Device/Revision code:',0F2h
	DB	'Switch DAC 6/8 bit:',0F2h
	DB	'Compatible VGA controller:',0F2h
	DB	'Program DAC during blank:',0F2h
	DB	'Hardware stereoscopic signaling:',0F2h
	DB	'Stereo signaling via VESA EVC:',0F2h
	DB	'PMID address via BIOS detect:',0F2h
	DB	'PM BIOS entry point:',0F2h
	DB	'PM init entry point:',0F2h
	DB	'BIOS Selector:',0F2h
	DB	'A0000 Selector:',0F2h
	DB	'B0000 Selector:',0F2h
	DB	'B8000 Selector:',0F2h
	DB	'Code Selector:',0F2h
	DB	'Protect Mode:',0F2h
	DB	'PMID address via func 0Ah:',0F2h
	DB	'PM code window call:',0F2h
	DB	'PM code display start:',0F2h
	DB	'PM code primary palette:',0F2h
	DB	'PM ports and memory table:',0h
vga_message_022:
	DB	'Yes',0h
	DB	0F4h,0Ch,ND_COLOR,'Fail: Header',0h
	DB	0F4h,0Eh,ND_COLOR,'Fail: Checksum',0h
	DB	0F4h,19h,ND_COLOR,'Fail: Header and checksum',0h
vga_message_023:
	DB	'No',0h
vga_message_024:
	DB	0F4h,1Ah,ND_COLOR,'VESA 3.0 or above required',0h
vga_message_025:
	DB	'Not detected',0h
vga_message_026:
	DB	'- ',0F4h,1Fh,ND_COLOR,'Invalid reported VESA VRAM size',0h
vga_message_027:
	DB	'Read EDID controller: 0',0h
vga_message_028:
	DB	'Alert message',0h
vga_message_029:
	DB	'VESA BIOS doesn''t support EDID reading',0h
vga_message_030:
	DB	'Select video controller',0h
vga_message_031:
	DB	'Controller:   -',0h
vga_message_032:
	DB	'Invalid EDID structure: try to decode or view binary?',0h
vga_message_033:
	DB	'N/A',0h
vga_message_034:
	DB	'[T]=Try do decode, [B]=View binary',0h
vga_message_035:
	DB	'EDID Information',0h
vga_message_036:
	DB	'Video controller number:',0F2h
	DB	'DDC 1 supported:',0F2h
	DB	'DDC 2 supported:',0F2h
	DB	'Blank screen during data transfer:',0F2h
	DB	'Approximate time to transfer data:',0h
vga_message_037:
	DB	'View binary EDID',0h
vga_message_038:
	DB	'[',11h,10h,', Home, End]=Navigate pages',0F0h
	DB	'[ESC]=Exit',0F0h
	DB	'[F1]=This help',0F0h
	DB	'[B]=Show binary EDID',0F0h
	DB	'[S]=Save EDID to file',0F0h
	DB	'[E]=Read extension block',0h
vga_message_039:
	DB	'µPage:  /',N_EDID_PAGE + '0','Æ',0h
vga_message_040:
	DB	'Padding structure:',0F2h
	DB	'EDID Version:',0F2h
	DB	'EDID Revision:',0F2h
	DB	'Checksum value:',0F2h
	DB	'Extension Block Count:',0F2h
	DB	'Valid EDID:',0h
vga_message_041:
	DB	'EDID Binary file saved to EDID    .BIN',0h
vga_message_042:
	DB	'You cannot create more than ten thousand files',0h
vga_message_043:
	DB	'Unable to save EDID binary file',0h
vga_message_044:
	DB	'Saving EDID file ...',0h
vga_message_045:
	DB	'Monitor doesn''t support EDID',0h
vga_message_046:
	DB	'Read EDID error or not supported by BIOS or monitor',0h
vga_message_047:
	DB	'[',11h,10h,', Home, End]=Navigate pages',0F0h
	DB	'[ESC]=Exit',0F0h
	DB	'[F1]=This help',0h
vga_message_048:
	DB	'Manufacturer ID:',0F2h
	DB	'Monitor model ID:',0F2h
	DB	'Serial number:',0F2h
	DB	'Year of manufacture:',0F2h
	DB	'Week of manufacture:',0h
vga_message_049:
	DB	0F4h,17h,ND_COLOR,'Invalid Manufacturer ID',0h
vga_message_050:
	DB	0F4h,0Dh,EXTRA_COLOR,'Not specified',0h
vga_message_051:
	DB	0F4h,1Bh,ND_COLOR,'Invalid Week of manufacture',0h
vga_message_052:
	DB	'Maximum horizontal size:',0F2h
	DB	'Maximum vertical size:',0h
vga_message_053:
	DB	'Aspect Ratio (Landscape):',0h
vga_message_054:
	DB	'Aspect Ratio (Portrait):',0h
vga_message_055:
	DB	'Continuous frequency display:',0F2h
	DB	'Native preferred Timing Mode:',0F2h
	DB	'sRGB is the default color space:',0F2h
	DB	'Active Off supported:',0F2h
	DB	'Suspend Mode is supported:',0F2h
	DB	'Standby Mode is supported:',0F2h
	DB	'Video Signal Interface:',0F2h
	DB	0F5h,0h,'Display Color Type:',0F2h
	DB	0F5h,0h,'Serration on the Vertical Sync:',0F2h
	DB	0F5h,0h,'Composite Signal on Green Video:',0F2h
	DB	0F5h,0h,'Composite Signal on Hor Sync:',0F2h
	DB	0F5h,0h,'Separate Sync H & V Signals:',0F2h
	DB	0F5h,0h,'Video Setup:',0F2h
	DB	0F5h,0h,'Signal Level Standard:',0F2h
	DB	0F5h,80h,'Supported Color Encoding Format/s:',0F2h
	DB	0F5h,80h,'Digital Video Interface Standard:',0F2h
	DB	0F5h,80h,'Color Bit Depth:',0h
vga_message_056:
	DB	0F4h,2h,COLOR_BASE,'cm',0h
vga_message_057:
	DB	'Analog',0h
vga_message_058:
	DB	'Digital',0h
vga_message_059:
	DB	'Monochrome or Grayscale display',0h
	DB	'RGB color display',0h
	DB	'Non-RGB color display',0h
	DB	'Display Color Type is Undefined',0h
vga_message_060:
	DB	'RGB 4:4:4',0h
	DB	'RGB 4:4:4 & YCrCb 4:4:4',0h
	DB	'RGB 4:4:4 & YCrCb 4:2:2',0h
	DB	'RGB 4:4:4 & YCrCb 4:4:4 & YCrCb 4:2:2',0h
vga_message_061:
	DB	'Digital Interface is not defined',0h
	DB	'DVI is supported',0h
	DB	'HDMI-a is supported',0h
	DB	'HDMI-b is supported',0h
	DB	'MDDI is supported',0h
	DB	'DisplayPort is supported',0h
	DB	WRITE_RESERVED_ID
vga_message_062:
	DB	0F4h,0Ch,COLOR_BASE,'Reserved[  ]',0h
vga_message_063:
	DB	'Color Bit Depth is undefined',0h
	DB	'6 Bits per Primary Color',0h
	DB	'8 Bits per Primary Color',0h
	DB	'10 Bits per Primary Color',0h
	DB	'12 Bits per Primary Color',0h
	DB	'14 Bits per Primary Color',0h
	DB	'16 Bits per Primary Color',0h
	DB	'Reserved (Do Not Use)',0h
vga_message_064:
	DB	'Blank Level = Black Level',0h
	DB	'Blank-to-Black setup or pedestal',0h
vga_message_065:
	DB	'0.700 : 0.300 : 1.000 V p-p',0h
	DB	'0.714 : 0.286 : 1.000 V p-p',0h
	DB	'1.000 : 0.400 : 1.400 V p-p',0h
	DB	'0.700 : 0.000 : 0.700 V p-p',0h
vga_message_066:
	DB	'Gamma factor:',0F2h,0F2h
	DB	'Red/Green LSB:',0F2h
	DB	'Blue/White LSB:',0F2h
	DB	'Red-x MSB:',0F2h
	DB	'Red-y MSB:',0F2h
	DB	'Green-x MSB:',0F2h
	DB	'Green-y MSB:',0F2h
	DB	'Blue-x MSB:',0F2h
	DB	'Blue-y MSB:',0F2h
	DB	'White-x MSB:',0F2h
	DB	'White-y MSB:',0F2h,0F2h
	DB	'Red X coordinate:',0F2h
	DB	'Red Y coordinate:',0F2h
	DB	'Green X coordinate:',0F2h
	DB	'Green Y coordinate:',0F2h
	DB	'Blue X coordinate:',0F2h
	DB	'Blue Y coordinate:',0F2h
	DB	'White X coordinate:',0F2h
	DB	'White Y coordinate:',0h
vga_message_067:
	DB	'Alphanumeric Data String:',0F2h
	DB	'Display Product Name:',0F2h
	DB	'Display Product Serial Number:',0F2h,0F2h
	DB	'Minimum Vertical Rate:',0F2h
	DB	'Maximum Vertical Rate:',0F2h
	DB	'Minimum Horizontal Rate:',0F2h
	DB	'Maximum Horizontal Rate:',0F2h
	DB	'Maximum Pixel Clock:',0F2h,0F2h
	DB	'Video Timing Support:',0h
vga_message_068:
	DB	'*** Standard video modes ***',0h
vga_message_069:
	DB	'720x400@70Hz (VGA):',0F2h
	DB	'720x400@88Hz (XGA2):',0F2h
	DB	'640x480@60Hz (VGA):',0F2h
	DB	'640x480@67Hz (Apple):',0F2h
	DB	'640x480@72Hz (VESA):',0F2h
	DB	'640x480@75Hz (VESA):',0F2h
	DB	'800x600@56Hz (VESA):',0F2h
	DB	'800x600@60Hz (VESA):',0F2h
	DB	'800x600@72Hz (VESA):',0F2h
	DB	'800x600@75Hz (VESA):',0F2h
	DB	'832x624@75Hz (Apple):',0F2h
	DB	'1024x768@87iHz (8514A):',0F2h
	DB	'1024x768@60Hz (VESA):',0F2h
	DB	'1024x768@70Hz (VESA):',0F2h
	DB	'1024x768@75Hz (VESA):',0F2h
	DB	'1280x1024@75Hz (VESA):',0F2h
	DB	'1152x870@75Hz (Apple):',0h
vga_message_070:
	DB	'*** Manufacturer extra video modes ***',0h
vga_message_071:
	DB	0F4h,1,COLOR_BASE,'x',0h
vga_message_072:
	DB	0F4h,1,COLOR_BASE,'@',0h
vga_message_073:
	DB	0F4h,2,COLOR_BASE,'Hz',0h
vga_message_074:
	DB	' Descriptor ',0h
vga_message_075:
	DB	0F3h,0Ch,'- ',0F3h,0Ch,'- ',0F3h,0Ch,'- ',0F3h,0Ch,'-',0h
vga_message_076:
	DB	'Pixel Clock:',0F2h
	DB	'Horizontal Addressable:',0F2h
	DB	'Horizontal Blanking:',0F2h
	DB	'Vertical Addressable:',0F2h
	DB	'Vertical Blanking:',0F2h
	DB	'Horizontal Front Porch:',0F2h
	DB	'Horizontal Sync Pulse:',0F2h
	DB	'Vertical Front Porch:',0F2h
	DB	'Vertical Sync Pulse:',0F2h
	DB	'Horizontal Image Size:',0F2h
	DB	'Vertical Image Size:',0F2h
	DB	'L/R Horizontal Border:',0F2h
	DB	'T/B Vertical Border:',0F2h
	DB	'Interlaced:',0F2h
	DB	'Stereo Viewing Support:',0F2h
	DB	'Signal:',0F2h
	DB	'Sync:',0F2h
	DB	'Serration:',0F2h
	DB	'Analog Sync On:',0F2h
	DB	'Digital V Polarity:',0F2h
	DB	'Digital H Polarity:',0h
vga_message_077:
	DB	'Not used',0h
vga_message_078:
	DB 	0F4h,3h,COLOR_BASE,'MHz',0h
vga_message_079:
	DB 	0F4h,3h,COLOR_BASE,'Pxl',0h
vga_message_080:
	DB	0F4h,2h,COLOR_BASE,'mm',0h
vga_message_081:
	DB	'No Stereo',0h
	DB	0F6h
	DW	OFFSET vga_message_081
	DB	'[1]',0h
	DB	'Field Right',0h
	DB	'Field Left',0h
	DB	'2-way Right',0h
	DB	'2-way Left',0h
	DB	'4-way',0h
	DB	'Side-by-Side',0h
vga_message_082:
	DB	'Composite',0h
	DB	'Bipolar',0h
vga_message_083:
	DB	'Composite',0h
	DB	'Separate',0h
vga_message_084:
	DB	'Green',0h
	DB	'RGB',0h
vga_message_085:
	DB	'N/S',0h
vga_message_086:
	DB	'[-]',0h
	DB	'[+]',0h
vga_message_087:
	DB	'None',0h
vga_message_088:
	DB	0F4h,1Ch,ND_COLOR,'Invalid Display Range Limits',0h
vga_message_089:
	DB	0F4h,12h,ND_COLOR,'Invalid descriptor',0h
vga_message_090:
	DB	0F4h,3h,COLOR_BASE,'KHz',0h
vga_message_091:
	DB	'No GTF',0h
	DB	'Only Standard and Detailed Timings',0h
	DB	WRITE_RESERVED_ID
vga_message_092:
	DB	'Default GTF',0h
	DB	'Range Limits Only',0h
	DB	'Secondary GTF',0h
	DB	'undefined[',0F4h,2h,ND_COLOR,'03]',0h
	DB	'CVT',0h
	DB	WRITE_RESERVED_ID
vga_message_093:
	DB	'Start break frequency:',0F2h
	DB	'C x 2:',0F2h
	DB	'M:',0F2h
	DB	'K:',0F2h
	DB	'J x 2:',0h
vga_message_094:
	DB	'CVT Standard Version Number:',0F2h
	DB	'Additional Pixel Clock Precision:',0F2h
	DB	'Maximum Active Pixels per Line:',0F2h
	DB	'Supported Aspect Ratios:',0F2h
	DB	'Preferred Aspect Ratio:',0F2h
	DB	'Standard CVT Blanking is supported:',0F2h
	DB	'Reduced CVT Blanking is supported:',0F2h
	DB	'Type of Display Scaling Supported:',0F2h
	DB	'Preferred Vertical Refresh Rate:',0h
vga_message_095:
	DB	'00',0h
	DB	'25',0h
	DB	'50',0h
	DB	'75',0h
vga_message_096:
	DB	'4:3',0h
	DB	'16:9',0h
	DB	'16:10',0h
	DB	'5:4',0h
	DB	'15:9',0h
	DB	WRITE_RESERVED_ID
vga_message_097:
	DB	0F4h,12h,ND_COLOR,'Invalid data',0h
vga_Message_098:
	DB	'H Shrink',0h
	DB	'H Stretch',0h
	DB	'V Shrink',0h
	DB	'V Stretch',0h
vga_message_099:
	DB	'Only main block',0h
vga_message_100:
	DB	0F4h,0Fh,ND_COLOR,'Unknown version',0h
vga_message_101:
	DB	0F4h,10h,ND_COLOR,'Unknown revision',0h
vga_message_102:
	DB	0F6h
	DW	OFFSET vga_message_074
	DB	'1',0F6h
	DW	OFFSET vga_message_074
	DB	'2',0F6h
	DW	OFFSET vga_message_074
	DB	'3',0F6h
	DW	OFFSET vga_message_074
	DB	'4',0h
vga_message_103:
	DB	'First White Point Index Number:',0F2h
	DB	'White X coordinate:',0F2h
	DB	'White Y coordinate:',0F2h
	DB	'Gamma factor:',0F2h,0F2h
	DB	'Second White Point Index Number:',0F2h
	DB	'White X coordinate:',0F2h
	DB	'White Y coordinate:',0F2h
	DB	'Gamma factor:',0F2h,0F2h
	DB	'Red a3:',0F2h
	DB	'Red a2:',0F2h
	DB	'Green a3:',0F2h
	DB	'Green a2:',0F2h
	DB	'Blue a3:',0F2h
	DB	'Blue a2:',0F2h,0F2h
	DB	'Standard Timing Definition:',0h
vga_message_104:
	DB	'CVT Version number:',0F2h,0F2h
	DB	'Coordinate Video Timing 1:',0F2h
	DB	'Standard Blanking 1:',0F2h
	DB	'Coordinate Video Timing 2:',0F2h
	DB	'Standard Blanking 2:',0F2h
	DB	'Coordinate Video Timing 3:',0F2h
	DB	'Standard Blanking 3:',0F2h
	DB	'Coordinate Video Timing 4:',0F2h
	DB	'Standard Blanking 4:',0h
vga_message_105:
	DB	'50',0F4h,2,COLOR_BASE,'Hz',0h
	DB	'60',0F4h,2,COLOR_BASE,'Hz',0h
	DB	'75',0F4h,2,COLOR_BASE,'Hz',0h
	DB	'85',0F4h,2,COLOR_BASE,'Hz',0h
Vga_message_106:
	DB	'50Hz',0h
	DB	'60Hz',0h
	DB	'75Hz',0h
	DB	'85Hz',0h
	DB	'60Hz(CVT)',0h
vga_message_107:
	DB	'640x350@85Hz:',0F1h,0Bh,'1280x1024@85Hz:',0F1h,0Bh,'1600x1200@65Hz:',0F2h
	DB	'640x400@85Hz:',0F1h,0Ch,'1360x768@60Hz:',0F1h,0Bh,'1600x1200@70Hz:',0F2h
	DB	'720x400@85Hz:',0F1h,8h,'1440x900@60Hz(RB):',0F1h,0Bh,'1600x1200@75Hz:',0F2h
	DB	'640x480@85Hz:',0F1h,0Ch,'1440x900@60Hz:',0F1h,0Bh,'1600x1200@85Hz:',0F2h
	DB	'848x480@60Hz:',0F1h,0Ch,'1440x900@75Hz:',0F1h,0Bh,'1792x1344@60Hz:',0F2h
	DB	'800x600@85Hz:',0F1h,0Ch,'1440x900@85Hz:',0F1h,0Bh,'1792x1344@75Hz:',0F2h
	DB	'1024x768@85Hz:',0F1h,7h,'1400x1050@60Hz(RB):',0F1h,0Bh,'1856x1392@60Hz:',0F2h
	DB	'1152x864@75Hz:',0F1h,0Bh,'1400x1050@60Hz:',0F1h,0Bh,'1856x1392@75Hz:',0F2h
	DB	'1280x768@60Hz(RB):',0F1h,0Bh,'1400x1050@75Hz:',0F1h,7h,'1920x1200@60Hz(RB):',0F2h
	DB	'1280x768@60Hz:',0F1h,0Bh,'1400x1050@85Hz:',0F1h,0Bh,'1920x1200@60Hz:',0F2h
	DB	'1280x768@75Hz:',0F1h,7h,'1680x1050@60Hz(RB):',0F1h,0Bh,'1920x1200@75Hz:',0F2h
	DB	'1280x768@85Hz:',0F1h,0Bh,'1680x1050@60Hz:',0F1h,0Bh,'1920x1200@85Hz:',0F2h
	DB	'1280x960@60Hz:',0F1h,0Bh,'1680x1050@75Hz:',0F1h,0Bh,'1920x1440@60Hz:',0F2h
	DB	'1280x960@85Hz:',0F1h,0Bh,'1680x1050@85Hz:',0F1h,0Bh,'1920x1440@75Hz:',0F2h
	DB	'1280x1024@60Hz:',0F1h,0Bh,'1600x1200@60Hz:',0F1h,1Ah,0h
vga_message_108:
	DB	0F4h,4h,ND_COLOR,'NoID',0h
vga_message_109:
	DB	'No extra extension block',0h
vga_message_110:
	DB	'Controller:   - Extension block: ',0h
vga_message_111:
	DB	'[',11h,10h,', Home, End]=Navigate extension blocks',0F0h
	DB	'[ESC]=Exit',0F0h
	DB	'[F1]=This help',0F0h
	DB	'[S]=Save Extension block to file',0F0h
	DB	'[G]=Go to extension block',0h
vga_message_112:
	DB	'ÆÍÍÍÍ',0h
vga_message_113:
	DB	'Unable to read extension block',0h
vga_message_114:
	DB	'VESA BIOS doesn''t support extended block reading',0h
vga_message_115:
	DB	'Choice extension block',0h
vga_message_116:
	DB	'[ESC]=Exit, [ENTER]=Select',0h
vga_message_117:
	DB	'Extension block:',0h
vga_message_118:
	DB	0F3h,?,' ',0h
vga_message_119:
	DB	'Invalid video mode for linear memory model',0h
vga_message_120:
	DB	'Saving extension block file ...',0h
vga_message_121:
	DB	'Extension block file saved to EDID    .EXT',0h
vga_message_122:
	DB	'Unable to save extension block file',0h
vga_message_123:
	DB	'VBE/PM standard not supported',0h
vga_message_124:
	DB	'VBE/PM version:',0F2h,0F2h
	DB	'Standby supported:',0F2h
	DB	'Suspend supported:',0F2h
	DB	'Off supported:',0F2h
	DB	'Reduced on supported:',0h
vga_message_125:
	DB	'VBE/PM capabilities',0h
vga_message_126:
	DB	'[ESC]=Exit, [F10]=Set display power state',0h
vga_message_127:
	DB	'No power state types supported',0h
vga_message_128:
	DB	'Press [1] for Standby',0h
	DB	'Press [2] for Suspend',0h
	DB	'Press [3] for Off',0h
	DB	'Press [4] for Reduced on',0h
vga_message_129:
	DB	'VBE/PM Set display power state',0h
vga_message_130:
	DB	0F4h,26h,POWER_COLOR,'Press ANY key to exit from power state',0h
vga_message_131:
	DB	'Standby power state: ON',0h
vga_message_132:
	DB	'Suspend power state: ON',0h
vga_message_133:
	DB	'Off power state: ON',0h
vga_message_134:
	DB	'Reduced on power state: ON',0h
vga_message_135:
	DB	'Saving screenshot file ...',0h
vga_message_136:
	DB	'Screenshot file saved to FILE    .LBM',0h
vga_message_137:
	DB	'Unable to save screenshot',0h
vga_message_138:
	DB	'VESA test selector',0h
vga_message_139:
	DB	'[',18h,19h,', Home, End, PgUp, PgDn]=Navigate',0F0h
	DB	'[ENTER]=Select VESA test',0F0h
	DB	'[ESC]=Exit',0F0h
	DB	'[F1]=This help',0F0h
	DB	'[F8]=Toggle AVX tests',0F0h
	DB	'[F9]=Toggle int 10h/pointer mode',0F0h
	DB	'[F10]=Toggle banked/linear mode',0h
vga_message_140:
	DB	'Detailed video mode information',0h
	DB	' Test VRAM memory access speed',0h
	DB	0F1h,5h,'Test VRAM reliability',0h
	DB	0F1h,3h,'Detect video scan timings',0h
	DB	' Test video mode visualization',0h
	DB	0F1h,3h,'Test dual page video mode',0h
	DB	0F1h,4h,'Test virtual resolution',0h
	DB	0F1h,4h,'Test switch 6/8 bit DAC',0h
	DB	' Detect available video memory',0h
vga_message_141:
	DB	0F4h,7h,TOGGLE_COLOR,'Int 10h',0h
	DB	0F4h,7h,TOGGLE_COLOR,'Pointer',0h
vga_message_142:
	DB	'µWindow function call:',0F3h,8h,' ÆÍµMemory access:',0F3h,7h,' ÆÍµAVX support: ',0h
vga_message_143:
	DB	0F4h,6h,TOGGLE_COLOR,'Banked',0h
	DB	0F4h,6h,TOGGLE_COLOR,'Linear',0h
vga_message_144:
	DB	'Error during VESA video mode information request',0h
vga_message_145:
	DB	'Video mode information',0h
vga_message_146:
	DB	'[ESC]=Close window',0h
vga_message_147:
	DB	'Video mode:',0F2h
	DB	'Hardware support:',0F2h
	DB	'BIOS support:',0F2h
	DB	'Color mode:',0F2h
	DB	'Mode type:',0F2h
	DB	'Compatible VGA controller:',0F2h
	DB	'VGA banked memory model:',0F2h
	DB	'Linear frame buffer:',0F2h
	DB	'Double scan mode:',0F2h
	DB	'Interlaced mode:',0F2h
	DB	'Hardware triple buffer:',0F2h
	DB      'Hardware stereoscopic mode:',0F2h
	DB      'Dual display start address:',0F2h
	DB	'Window A relocatable:',0F2h
	DB	'Window A readable:',0F2h
	DB	'Window A writeable:',0F2h
	DB	'Window A segment:',0F2h
	DB	'Window B relocatable:',0F2h
	DB	'Window B readable:',0F2h
	DB	'Window B writeable:',0F2h
	DB	'Window B segment:',0F2h
	DB	'Window granularity:',0F2h
	DB	'Window size:',0F2h
	DB	'Pointer to window function:',0F2h
	DB	'Byte per scan line:',0F2h
	DB	'Horizontal resolution:',0F2h
	DB	'Vertical resolution:',0F2h
	DB	'Character cell width:',0F2h
	DB	'Character cell height:',0F2h
	DB	'Number of memory planes:',0h
vga_message_148:
	DB	'Bit per pixel:',0F2h
	DB	'Number of banks:',0F2h
	DB	'Memory model type:',0F2h
	DB	'Bank size:',0F2h
	DB	'Number of display pages:',0F2h
	DB	'Red mask size:',0F2h
	DB	'Red mask offset:',0F2h
	DB	'Green mask size:',0F2h
	DB	'Green mask offset:',0F2h
	DB	'Blue mask size:',0F2h
	DB	'Blue mask offset:',0F2h
	DB	'Rsv mask size:',0F2h
	DB	'Rsv mask offset:',0F2h
	DB	'Programmable color ramp:',0F2h
	DB	'Rsv bits are usable:',0F2h
	DB	'Linear physical address:',0F2h
	DB	'Off screen memory pointer:',0F2h
	DB	'Off screen memory:',0F2h
	DB	'Linear byte per line:',0F2h
	DB	'Bank display pages:',0F2h
	DB	'Linear display pages:',0F2h
	DB	'Linear red mask size:',0F2h
	DB	'Linear red mask offset:',0F2h
	DB	'Linear green mask size:',0F2h
	DB	'Linear green mask offset:',0F2h
	DB	'Linear blue mask size:',0F2h
	DB	'Linear blue mask offset:',0F2h
	DB	'Linear rsv mask size:',0F2h
	DB	'Linear rsv mask offset:',0F2h
	DB	'Maximum pixel clock in Hz:',0h
vga_message_149:
	DB	'TEXT',0h
	DB	'GRAPHIC',0h
vga_message_150:
	DB	0F4h,5h,COLOR_BASE,'KiB/s',0h
vga_message_151:
	DB	0F4h,3h,ND_COLOR,'N/S',0h
vga_message_152:
	DB	'Text',0h
	DB	'CGA',0h
	DB	'Hercules',0h
	DB	'4-Planar',0h
	DB	'Packed pixel',0h
	DB	'Non chain 4',0h
	DB	'Direct color',0h
	DB	'YUV',0h
	DB	WRITE_RESERVED_ID
vga_message_153:
	DB	0F4h,7h,TOGGLE_COLOR,'Ignored',0h
vga_message_154:
	DB	'This test supports only 8-bit packed pixel or direct color video mode',0h
vga_message_155:
	DB	'Video mode not supported by current hardware',0h
vga_message_156:
	DB	'Invalid horizontal/vertical resolution',0h
vga_message_157:
	DB	'Invalid bits per pixel for the selected video mode',0h
vga_message_158:
	DB	'Invalid direct color RGB mask',0h
vga_message_159:
	DB	'Invalid bytes per scan line. Try to correct?',0h
vga_message_160:
	DB	'[Y]=Yes, [N]=No',0h
vga_message_161:
	DB	'Windowed memory mode is not available',0h
vga_message_162:
	DB	'Invalid WinSize for the selected video mode',0h
vga_message_163:
	DB	'Invalid WinGranularity for the selected video mode',0h
vga_message_164:
	DB	'Invalid window segment for the selected video mode',0h
vga_message_165:
	DB	'Invalid window segment. Try to correct?',0h
vga_message_166:
	DB	'Error opening VESA video mode',0h
vga_message_167:
	DB	'The selected video mode seems to be unavailable. Continue anyway?',0h
vga_message_168:
	DB	'Linear mode unavailable due to active Virtual 8086 mode',0h
vga_message_169:
	DB	'Linear mode unavailable due to inactive A20 line',0h
vga_message_170:
	DB	'Video BIOS VESA 2.0 unavailable',0h
vga_message_171:
	DB	'Linear memory mode is not available',0h
vga_message_172:
	DB	'Invalid linear physical address',0h
vga_message_173:
	DB	'Invalid WinFuncPtr for the selected video mode',0h
vga_message_174:
	DB	'µVESA video mode speed results with overheadÆÍÍÍ',0h
	DB	'µVESA video mode speed results without overheadÆ',0h
	DB	'µMean overhead expressed in PIT cyclesÆ',0F3h,9h,'Í',0h
	DB	'µMean overhead expressed as a percentageÆ',0F3h,7h,'Í',0h
vga_message_175:
	DB	'Video mode:',0F2h
	DB	'Memory model:',0F2h
	DB	'Timer overhead:',0h
vga_message_176:
	DB	'Read 8b:',0F2h,0F2h
	DB	'Read 16b:',0F2h,0F2h
	DB	'Read 32b:',0F2h,0F2h
	DB	'Read 64b:',0F2h,0F2h
	DB	'Read 128b:',0F2h,0F2h
	DB	'Read 256b:',0F2h,0F2h
	DB	'Read 512b:',0F2h,0F2h
	DB	'Write 8b:',0F2h,0F2h
	DB	'Write 16b:',0F2h,0F2h
	DB	'Write 32b:',0F2h,0F2h
	DB	'Write 64b:',0F2h,0F2h
	DB	'Write 128b:',0F2h,0F2h
	DB	'Write 256b:',0F2h,0F2h
	DB	'Write 512b:',0h
vga_message_177:
	DB	'Linear/Unreal',0h
vga_message_177a:
	DB	'Window via Int 10h/Real',0h
vga_message_177b:
	DB	'Window via Call pointer/Real',0h
	DB	'Linear/Unreal + AVX-PM16/Unreal',0h
	DB	'Window via Int 10h/Real + AVX-PM16/Unreal',0h
	DB	'Window via Call pointer/Real + AVX-PM16/Unreal',0h
vga_message_178:
	DB	'ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0F3h,4h,' ï',0h
vga_message_179:
	DB	'Math coprocessor not present',0h
vga_message_180:
	DB	'SSE instructions not supported',0h
vga_message_181:
	DB	'AVX instructions not supported',0h
vga_message_182:
	DB	'AVX-512F instructions not supported',0h
vga_message_183:
	DB	0F3h,?,'Û',0h
vga_message_184:
	DB	0F4h,0Ah,COLOR_BASE,'PIT cycles',0h
vga_message_185:
	DB	'[ESC]=Close window, [',11h,10h,', Home, End]=Navigate pages',0h
vga_message_186:
	DB	0F3h,TEXT_WIDTH - 10h,' ',0h
vga_message_187:
	DB	0F4h,5h,COLOR_BASE,'PITcy',0h
vga_message_188:
	DB	0F4h,1h,COLOR_BASE,'%',0h
vga_message_189:
	DB	0F4h,2h,TOGGLE_COLOR,'OnÆÍ',0h
vga_message_190:
	DB	0F4h,3h,TOGGLE_COLOR,'OffÆÍ',0h
vga_message_191:
	DB	'SSE not performed due to active Virtual 8086 mode',0h
vga_message_192:
	DB	'AVX not performed due to active Virtual 8086 mode',0h
vga_message_193:
	DB	'AVX not performed due to inactive A20 line',0h
vga_message_194:
	DB	'AVX not performed due to user setting',0h
vga_message_195:
	DB	'AVX512 not performed due to active Virtual 8086 mode',0h
vga_message_196:
	DB	'AVX512 not performed due to inactive A20 line',0h
vga_message_197:
	DB	'AVX512 not performed due to user setting',0h
vga_message_198:
	DB	'Undetectable video RAM size',0h
vga_message_199:
	DB	'VESA video RAM size',0h
vga_message_200:
	DB	'Video mode:',0F2h
	DB	'Memory model:',0F2h
vga_message_200a:
	DB	'Video RAM size:',0h
vga_message_201:
	DB	'This test supports only packed/planar or direct color video mode',0h
vga_message_202:
	DB	'Total video modes: ',0h
vga_message_203:
	DB	0F4h,5h,COLOR_BASE,'MiB/s',0h
vga_message_204:
	DB	'Video scan timings',0h
vga_message_205:
	DB	'Video mode:',0F2h
	DB	'Linear mode:',0F2h
	DB	'Vertical refresh:',0F2h
	DB	'Horizontal refresh:',0F2h
	DB	'Bandwidth:',0F2h
	DB	'Interlaced:',0F2h
	DB	'Sync Integrity Score:',0F2h
	DB	'Samples:',0h
vga_message_206:
	DB	'Off',0h
	DB	'On',0h
vga_message_207:
	DB	'Enter the limits for the VRAM reliability test',0h
vga_message_208:
	DB	'[ESC]=Exit/Break during test, [ENTER]=Continue',0h
vga_message_209:
	DB	'Starting address:',0h
vga_message_210:
	DB	'VRAM Test size:',0h
vga_message_211:
	DB	'(0-',0h
vga_message_212:
	DB	'(1-',0h
vga_message_213:
	DB	0F4h,1Dh,ND_COLOR,'Emulated VGA Status register!',0h
vga_message_214:
	DB	0F4h,1Ch,ND_COLOR,'Emulated VGA CRTC registers!',0h
vga_message_215:
	DB	0F4h,6h,COLOR_BASE,'- å/æ:',0h
vga_message_216:
	DB	'Pass:',0F1h,4h,'(1-16)',0h
vga_message_217:
	DB	'0 :0 :0 -',0h
vga_message_218:
	DB	0F3h,8,'?-',0F1h,9h,0F3h,5h,'?%-',0h
vga_message_219:
	DB	'Video mode:',0F2h
	DB	'Memory model:',0F2h
	DB	'VRAM test offset:',0F2h
	DB	'VRAM test size:',0F2h
	DB	'Test pass:',0F2h
	DB	'VRAM errors:',0F2h
	DB	'Date:',0F2h
	DB	'Time:',0h
vga_message_220:
	DB	'VRAM Reliability test results',0h
vga_message_221:
	DB	'[ESC]=Close window, [F10]=View errors',0h
vga_message_222:
	DB	'X-VESA V',X_VESA_VERSION,' - View VRAM error log',0h
vga_message_223:
	DB	'[ESC]=Close window, [S]=Save report to file',0h
vga_message_224:
	DB	'Error',0F1h,3h,'Pass',0F1h,5h,'Time',0F1h,6h,'Offset',0F1h,4h,'Expected',0F1h,5h,'Read',0F1h,5h,'XOR Mask',0F1h,4h,'Type',0h
vga_message_225:
	DB	'Saving VRAM test LOG file ...',0h
vga_message_226:
	DB	'LOG txt file saved to FILE    .LOG',0h
vga_message_227:
	DB	'Unable to save LOG txt file',0h
vga_message_228:
	DB	'Video mode:',0h
vga_message_229:
	DB	'Memory model:',0h
vga_message_230:
	DB	'VRAM test offset:',0h
vga_message_231:
	DB	'VRAM test size:',0h
vga_message_232:
	DB	'Test pass:',0h
vga_message_233:
	DB	'VRAM errors:',0h
vga_message_234:
	DB	'VRAM test reports over 999 errors',0h
vga_message_235:
	DB	'Ñ',0F1h,6h,'Ñ',0F1h,0Ah,'Ñ',0F1h,0Ah,'Ñ',0F1h,0Ah,'Ñ',0F1h,0Ah,'Ñ',0F1h,0Ah,'Ñ',0F1h,8h,'»'
	DB	'º',0F1h,7h,'³',0F1h,6h,'³',0F1h,0Ah,'³',0F1h,0Ah,'³',0F1h,0Ah,'³',0F1h,0Ah,'³',0F1h,0Ah,'³',0F1h,8h,'º'
	DB	'Ç',0F3h,7h,'ÄÁ',0F3h,6h,'ÄÁ',0F3h,0Ah,'ÄÁ',0F3h,0Ah,'ÄÁ',0F3h,0Ah,'ÄÁ',0F3h,0Ah,'ÄÁ',0F3h,0Ah,'ÄÁ',0F3h,8h,'Ä¶',0h
vga_message_236:
	DB	'(AM)',0h
vga_message_237:
	DB	'(PM)',0h
vga_message_238:
	DB	'[ENTER]=Continue',0h
vga_message_239:
	DB	'VRAM reliability test interrupted by user',0h
vga_message_240:
	DB	'Cannot test VESA video mode with this exotic memory model',0h
vga_message_241:
	DB	'BITS',0h
	DB	'BURST',0h
	DB	'MATRIX',0h
vga_message_242:
	DB	'Date:',0h
vga_message_243:
	DB	'Time:',0h
vga_message_244:
	DB	'Invalid font size for VESA text mode',0h
vga_message_245:
	DB	'Press any key to close display',0h
vga_message_246:
	DB	'Available VRAM for each video mode',0h
vga_message_247:
	DB	'[ESC]=Exit, [F5]=Scan all video modes',0h
vga_message_248:
	DB	'Ñ',0F1h,7h,'Ñ',0F1h,7h,'Ñ',0F1h,7h,'Ñ',0F1h,0Eh,'Ñ',0F1h,0Fh,'Ñ',0F1h,0Fh,'»'
	DB	'º  Mode ³ X Res ³ Y Res ³ Bpp/M ³ Memory model ³  VRAM banked  ³  VRAM linear  º'
	DB	'Ç',0F3h,7h,'ÄÁ',0F3h,7h,'ÄÁ',0F3h,7h,'ÄÁ',0F3h,7h,'ÄÁ',0F3h,0Eh,'ÄÁ',0F3h,0Fh,'ÄÁ',0F3h,0Fh,'Ä¶',0h
vga_message_249:
	DB	0F1h,4h,'TEXT',0h
	DB	0F1h,5h,'CGA',0h
	DB	'  HERCULES',0h
	DB	'  4-PLANAR',0h
	DB	0F1h,3h,'PACKED',0h
	DB	' NON CHAIN 4',0h
	DB	'DIRECT COLOR',0h
	DB	0F1h,5h,'YUV',0h
	DB	WRITE_RESERVED_ID
vga_message_250:
	DB	0F4h,0Dh,ND_COLOR,'Not supported',0h
vga_message_251:
	DB	'Fail[  ]',0h
vga_message_252:
	DB	'Are you sure you want to scan all video modes?',0h
vga_message_253:
	DB	'Red',0h
	DB	'Green',0h
	DB	'Blue',0h
vga_message_254:
	DB	'Insufficient video memory for two pages',0h
vga_message_255:
	DB	'[ESC]=Close window, [D]=View distribution',0h
vga_message_256:
	DB	'Perfectly stable signal detected. All samples are identical',0h
vga_message_257:
	DB	'Horizontal frequency distribution',0h
vga_message_258:
	DB	0F4h,0FFh,COLOR_BASE,'MINX=',0h
vga_message_259:
	DB	'OEM name:',0F2h
	DB	'Video mode:',0F2h
	DB	'Samples:',0F2h
	DB	'Statistics:',0F2h
	DB	'Navigation:',0h
vga_message_260:
	DB	'Distribution for horizontal frequency not available',0h
vga_message_261:
	DB	0F4h,1h,COLOR_BASE,'- ',0F4h,0FFh,ND_COLOR,'Spurious sync pulses:',0h
vga_message_262:
	DB	0F4h,0FFh,ND_COLOR,'Excessive spurious sync pulses',0h
vga_message_263:
	DB	'[ESC]=Exit, [R]=Retest unlimited',0h
vga_message_264:
	DB	'VRAM check size without limits? (May cause the system to hang)',0h
vga_message_265:
	DB	0F4h,0FFh,COLOR_BASE,'MAXX=',0h
vga_message_266:
	DB	0F4h,0FFh,COLOR_BASE,'MAXY=',0h
vga_message_267:
	DB	0F4h,0FFh,COLOR_BASE,'N=',0h
vga_message_268:
	DB	0F4h,0FFh,COLOR_BASE,' - ',0h
vga_message_269:
	DB	0F4h,0FFh,COLOR_BASE,'ZOOM=',0h
vga_message_270:
	DB	0F4h,0FFh,COLOR_BASE,'SHIFT=',0h
vga_message_271:
	DB	'[+/-]=Zoom in/out +/- 10%',0F0h
	DB	'[',11h,10h,']=Horizontal shift +/- 1',0F0h
	DB	'[CTRL + ',11h,10h,']=Horizontal shift +/- 10',0F0h
	DB	'[DEL]=Reset to default view',0F0h
	DB	'[F1]=This help',0F0h
	DB	'[ESC]=Exit',0h
vga_message_272:
	DB	0F4h,0FFh,COLOR_BASE,'HF=',0h
vga_message_273:
	DB	0F4h,0FFh,COLOR_BASE,'/',0h
vga_message_274:
	DB	'ÇÄÄÄÂ',0F3h,74d,'Ä¶',0h
vga_message_275:
	DB	'ÇÄÄÄÁÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂ',0F3h,8d,'ÄÂÄ¶',0h
vga_message_276:
	DB	0F3h,?,'?',0h
vga_message_277:
	DB	'Dual page video move test',0h
	DB	'No flickering should be visible',0h
	DB	'Press [ESC] key to finish the test',0h
	DB	'Press [F10] key to toggle retrace',0h
	DB	'VGA retrace status:',0h
	DB	'VESA retrace status:',0h
	DB	'Current retrace: OFF VGA VESA',0h
vga_message_278:
	DB	'VESA Dual page mode flipping not supported',0h
vga_message_278a:
	DB	'VESA Dual page mode flipping fail',0h
vga_message_279:
	DB	'AVAILABLE',0h
vga_message_280:
	DB	'FAIL',0h
vga_message_281:
	DB	'VESA display start function not supported',0h
vga_message_281a:
	DB	'VESA display start function fail',0h
vga_message_282:
	DB	'VESA set/get logical scanline length not supported',0h
vga_message_283:
	DB	'Too many virtual modes. Insufficient memory',0h
vga_message_284:
	DB	'[ESC]=Exit, [ENTER]=Continue, [F10]=Choose from table',0h
vga_message_285:
	DB	'Enter the size of virtual horizontal resolution',0h
vga_message_286:
	DB	'Video mode:',0F2h
	DB	'Memory model:',0F2h
	DB	'Video RAM size:',0F2h
	DB	'Virtual video modes:',0F2h,0F2h
	DB	'Horizontal resolution:',0h
vga_message_287:
	DB	'Requested virtual width:',0F2h
	DB	'Available virtual width:',0h
vga_message_288:
	DB	'Pixel',0h
vga_message_289:
	DB	'Accept nearest value?',0h
vga_message_290:
	DB	'Unable to set desired virtual horizontal width',0h
vga_message_291:
	DB	'Virtual resolution:',0h
vga_message_292:
	DB	'Press [',11h,10h,18h,19h,'] for 1 pixel scrolling',0h
	DB	'Press [CTRL+',11h,10h,18h,19h,'] for 10 pixel scrolling',0h
	DB	'Press [DEL] to reset view',0h
	DB	'Press [ESC] to exit',0h
	DB	'Use MOUSE for scrolling too',0h
vga_message_293:
	DB	'Critical error handler - DIV/INTO exception',0h
vga_message_294:
	DB	'[ESC]=Terminate X-VESA',0h
vga_message_295:
	DB	'EAX =',0F2h
	DB	'EBX =',0F2h
	DB	'ECX =',0F2h
	DB	'EDX =',0F2h
	DB	'ESI =',0F2h
	DB	'EDI =',0F2h
	DB	'EBP =',0F2h
	DB	'ESP =',0F2h
	DB	'DS =',0F2h
	DB	'ES =',0F2h
	DB	'FS =',0F2h
	DB	'GS =',0F2h
	DB	'EFLAGS =',0F2h
	DB	'CS:IP =',0h
vga_message_296:
	DB	'This test supports only packed video mode',0h
vga_message_297:
	DB	'Invalid or not supported switch 6/8 bit DAC mode',0h
vga_message_298:
	DB	'The selected limits may cause the system to hang. Do you want to continue?',0h
vga_message_299:
	DB	'Choice virtual resolution',0h
vga_message_300:
	DB	'N',0F1h,4h,'Virtual resolution',0h
vga_message_301:
	DB	'Unable to read/write DAC registers',0h
vga_message_302:
	DB	'[+] or [SPACE] to toggle 6/8 bit color',0h
	DB	'Press [ESC] key to exit',0h
	DB	'At 8-bit one gradient must be visible',0h
vga_message_303:
	DB	'Red 6-bit',0h
	DB	'Green 6-bit',0h
	DB	'Blue 6-bit',0h
	DB	'Grey 6-bit',0h
vga_message_304:
	DB	'Too many VESA video modes. Only the first ',MAX_VESA_MODE_STR,' will be used',0h
vga_message_305:
	DB	'  Legacy (4095x4095)',0h
	DB	'Standard (16383x32767)',0h
	DB	' Insane (65535x65535)',0h
	DB	'   Custom selection',0h
vga_message_306:
	DB	'[ESC]=Exit, [ENTER]=Continue',0h
vga_message_307:
	DB	'Select virtual screen limits',0h
vga_message_308:
	DB	'Insert virtual screen limits',0h
vga_message_309:
	DB	'Start virtual horizontal scan:',0h
vga_message_310:
	DB	'End virtual horizontal scan:',0h
vga_message_311:
	DB	'Start virtual vertical scan:',0h
vga_message_312:
	DB	'End virtual vertical scan:',0h
vga_message_313:
	DB	'-65535)',0h
vga_message_314:
	DB	'[ESC]=Continue',0h
vga_message_315:
	DB	'VESA Display start alignment/bounds test',0h
vga_message_316:
	DB	'Horizontal alignment:',0F2h
	DB	'Horizontal bound:',0F2h
	DB	'Vertical alignment:',0F2h
	DB	'Vertical bound:',0F2h
	DB	'Horizontal granularity:',0h
vga_message_317:
	DB	'PROPER',0h
vga_message_318:
	DB	0F4h,0FFh,COLOR_BASE,'Bytes - ',0h
vga_message_319:
	DB	'UNTESTED',0h
vga_message_320:
	DB	'UNSUPPORTED',0h
vga_message_321:
	DB	0F4h,0FFh,COLOR_BASE,'Pixel',0h
vga_message_322:
	DB	'[ESC]=Exit, [S]=Save video BIOS ROM to file',0h
vga_message_323:
	DB	'Saving video BIOS ROM file ...',0h
vga_message_324:
	DB	'Video BIOS ROM file saved to FILE    .VBI',0h
vga_message_325:
	DB	'Unable to save video BIOS ROM file',0h
vga_message_326:
	DB	'No PCI device',0h

;-------------------------------------------------------------------------------

font_table_8x10:
	DB	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	DB	080h,080h,080h,080h,080h,080h,080h,080h,080h,080h
	DB	0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h
	DB	0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h
	DB	0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h
	DB	0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h,0F8h
	DB	0FCh,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh,0FCh
	DB	0FEh,0FEh,0FEh,0FEh,0FEh,0FEh,0FEh,0FEh,0FEh,0FEh
	DB	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	DB	000h,000h,03Ch,066h,042h,042h,066h,03Ch,000h,000h
	DB	0FFh,0FFh,0C3h,099h,0BDh,0BDh,099h,0C3h,0FFh,0FFh
	DB	000h,00Fh,007h,00Fh,07Dh,0CCh,0CCh,0CCh,078h,000h
	DB	000h,03Ch,066h,066h,066h,03Ch,018h,07Eh,018h,000h
	DB	000h,03Fh,033h,03Fh,030h,030h,070h,0F0h,0E0h,000h
	DB	000h,07Fh,063h,07Fh,063h,063h,067h,0E6h,0C0h,000h
	DB	000h,099h,05Ah,03Ch,0E7h,0E7h,03Ch,05Ah,099h,000h
	DB	000h,080h,0E0h,0F8h,0FEh,0F8h,0E0h,080h,000h,000h
	DB	000h,002h,00Eh,03Eh,0FEh,03Eh,00Eh,002h,000h,000h
	DB	018h,03Ch,07Eh,018h,018h,018h,07Eh,03Ch,018h,000h
	DB	066h,066h,066h,066h,066h,066h,000h,066h,000h,000h
	DB	07Fh,0DBh,0DBh,0DBh,07Bh,01Bh,01Bh,01Bh,000h,000h
	DB	03Eh,063h,038h,06Ch,06Ch,038h,0CCh,078h,000h,000h
	DB	000h,000h,000h,000h,000h,07Eh,07Eh,07Eh,000h,000h
	DB	000h,018h,03Ch,07Eh,018h,07Eh,03Ch,018h,0FFh,000h
	DB	018h,03Ch,07Eh,018h,018h,018h,018h,018h,000h,000h
	DB	018h,018h,018h,018h,018h,07Eh,03Ch,018h,000h,000h
	DB	000h,000h,018h,00Ch,0FEh,00Ch,018h,000h,000h,000h
	DB	000h,000h,030h,060h,0FEh,060h,030h,000h,000h,000h
	DB	000h,000h,000h,0C0h,0C0h,0C0h,0FEh,000h,000h,000h
	DB	000h,000h,024h,066h,0FFh,066h,024h,000h,000h,000h
	DB	000h,000h,018h,03Ch,07Eh,0FFh,0FFh,000h,000h,000h
	DB	000h,000h,0FFh,0FFh,07Eh,03Ch,018h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	DB	030h,078h,078h,030h,030h,030h,000h,030h,000h,000h
	DB	06Ch,06Ch,06Ch,000h,000h,000h,000h,000h,000h,000h
	DB	000h,06Ch,06Ch,0FEh,06Ch,0FEh,06Ch,06Ch,000h,000h
	DB	030h,07Ch,0C0h,0C0h,078h,00Ch,00Ch,0F8h,030h,000h
	DB	001h,0C3h,0C6h,00Ch,018h,030h,063h,0C3h,080h,000h
	DB	000h,038h,06Ch,038h,076h,0DCh,0CCh,076h,000h,000h
	DB	000h,060h,060h,0C0h,000h,000h,000h,000h,000h,000h
	DB	018h,030h,060h,060h,060h,060h,030h,018h,000h,000h
	DB	060h,030h,018h,018h,018h,018h,030h,060h,000h,000h
	DB	000h,000h,066h,03Ch,0FFh,03Ch,066h,000h,000h,000h
	DB	000h,000h,030h,030h,0FCh,030h,030h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,000h,030h,030h,060h,000h
	DB	000h,000h,000h,000h,0FCh,000h,000h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,000h,030h,030h,000h,000h
	DB	000h,006h,00Ch,018h,030h,060h,0C0h,080h,000h,000h
	DB	07Ch,0C6h,0CEh,0DEh,0F6h,0E6h,0C6h,07Ch,000h,000h
	DB	030h,070h,0F0h,030h,030h,030h,030h,0FCh,000h,000h
	DB	078h,0CCh,08Ch,018h,030h,060h,0CCh,0FCh,000h,000h
	DB	078h,0CCh,00Ch,038h,00Ch,00Ch,0CCh,078h,000h,000h
	DB	01Ch,03Ch,06Ch,0CCh,0FEh,00Ch,00Ch,01Eh,000h,000h
	DB	0FCh,0C0h,0C0h,0F8h,00Ch,00Ch,0CCh,078h,000h,000h
	DB	038h,060h,0C0h,0F8h,0CCh,0CCh,0CCh,078h,000h,000h
	DB	0FCh,08Ch,018h,018h,030h,030h,030h,078h,000h,000h
	DB	078h,0CCh,0CCh,078h,0CCh,0CCh,0CCh,078h,000h,000h
	DB	078h,0CCh,0CCh,07Ch,00Ch,00Ch,018h,070h,000h,000h
	DB	000h,000h,030h,030h,000h,000h,030h,030h,000h,000h
	DB	000h,000h,030h,030h,000h,000h,030h,030h,060h,000h
	DB	000h,018h,030h,060h,0C0h,060h,030h,018h,000h,000h
	DB	000h,000h,000h,0FCh,000h,000h,0FCh,000h,000h,000h
	DB	000h,060h,030h,018h,00Ch,018h,030h,060h,000h,000h
	DB	078h,0CCh,08Ch,018h,030h,030h,000h,030h,000h,000h
	DB	07Ch,0C6h,0D6h,0DEh,0DEh,0DCh,0C0h,078h,000h,000h
	DB	030h,078h,0CCh,0CCh,0FCh,0CCh,0CCh,0CCh,000h,000h
	DB	0FCh,066h,066h,07Ch,066h,066h,066h,0FCh,000h,000h
	DB	03Ch,066h,0C0h,0C0h,0C0h,0C0h,066h,03Ch,000h,000h
	DB	0F8h,06Ch,066h,066h,066h,066h,06Ch,0F8h,000h,000h
	DB	0FEh,062h,068h,078h,068h,060h,062h,0FEh,000h,000h
	DB	0FEh,062h,068h,078h,068h,060h,060h,0F0h,000h,000h
	DB	03Ch,066h,0C6h,0C0h,0CEh,0C6h,066h,03Ch,000h,000h
	DB	0CCh,0CCh,0CCh,0FCh,0CCh,0CCh,0CCh,0CCh,000h,000h
	DB	078h,030h,030h,030h,030h,030h,030h,078h,000h,000h
	DB	01Eh,00Ch,00Ch,00Ch,0CCh,0CCh,0CCh,078h,000h,000h
	DB	0E6h,066h,06Ch,078h,06Ch,066h,066h,0E6h,000h,000h
	DB	0F0h,060h,060h,060h,060h,062h,066h,0FEh,000h,000h
	DB	0C6h,0EEh,0FEh,0FEh,0D6h,0C6h,0C6h,0C6h,000h,000h
	DB	0C6h,0E6h,0F6h,0DEh,0CEh,0C6h,0C6h,0C6h,000h,000h
	DB	038h,06Ch,0C6h,0C6h,0C6h,0C6h,06Ch,038h,000h,000h
	DB	0FCh,066h,066h,066h,07Ch,060h,060h,0F0h,000h,000h
	DB	078h,0CCh,0CCh,0CCh,0CCh,0DCh,078h,01Ch,000h,000h
	DB	0FCh,066h,066h,07Ch,06Ch,066h,066h,0E6h,000h,000h
	DB	078h,0CCh,0E0h,070h,038h,01Ch,0CCh,078h,000h,000h
	DB	0FCh,0B4h,030h,030h,030h,030h,030h,078h,000h,000h
	DB	0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,078h,000h,000h
	DB	0CCh,0CCh,0CCh,0CCh,0CCh,0CCh,078h,030h,000h,000h
	DB	0C6h,0C6h,0C6h,0D6h,0FEh,0EEh,0C6h,0C6h,000h,000h
	DB	0C6h,0C6h,06Ch,038h,038h,06Ch,0C6h,0C6h,000h,000h
	DB	0CCh,0CCh,0CCh,078h,030h,030h,030h,078h,000h,000h
	DB	0FEh,0C6h,08Ch,018h,030h,062h,0C6h,0FEh,000h,000h
	DB	078h,060h,060h,060h,060h,060h,060h,078h,000h,000h
	DB	080h,0C0h,060h,030h,018h,00Ch,006h,002h,000h,000h
	DB	078h,018h,018h,018h,018h,018h,018h,078h,000h,000h
	DB	010h,038h,06Ch,0C6h,000h,000h,000h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0FFh,000h
	DB	030h,030h,018h,000h,000h,000h,000h,000h,000h,000h
	DB	000h,000h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h,000h
	DB	0E0h,060h,070h,06Ch,066h,066h,066h,0DCh,000h,000h
	DB	000h,000h,078h,0CCh,0C0h,0C0h,0CCh,078h,000h,000h
	DB	01Ch,00Ch,01Ch,06Ch,0CCh,0CCh,0CCh,076h,000h,000h
	DB	000h,000h,078h,0CCh,0FCh,0C0h,0CCh,078h,000h,000h
	DB	038h,06Ch,060h,0F0h,060h,060h,060h,0F0h,000h,000h
	DB	000h,000h,076h,0CCh,0CCh,07Ch,00Ch,08Ch,078h,000h
	DB	0E0h,060h,07Ch,066h,066h,066h,066h,0E6h,000h,000h
	DB	030h,000h,070h,030h,030h,030h,030h,078h,000h,000h
	DB	00Ch,000h,00Ch,00Ch,00Ch,0CCh,0CCh,078h,000h,000h
	DB	0E0h,060h,066h,06Ch,078h,06Ch,066h,0E6h,000h,000h
	DB	070h,030h,030h,030h,030h,030h,030h,078h,000h,000h
	DB	000h,000h,0CCh,0FEh,0D6h,0C6h,0C6h,0C6h,000h,000h
	DB	000h,000h,0F8h,0CCh,0CCh,0CCh,0CCh,0CCh,000h,000h
	DB	000h,000h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h,000h
	DB	000h,000h,0DCh,066h,066h,07Ch,060h,060h,0F0h,000h
	DB	000h,000h,076h,0CCh,0CCh,07Ch,00Ch,00Ch,01Eh,000h
	DB	000h,000h,0DCh,0F6h,066h,060h,060h,0F0h,000h,000h
	DB	000h,000h,07Ch,0C4h,070h,038h,08Ch,0F8h,000h,000h
	DB	010h,030h,07Ch,030h,030h,030h,034h,018h,000h,000h
	DB	000h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h,000h
	DB	000h,000h,0CCh,0CCh,0CCh,0CCh,078h,030h,000h,000h
	DB	000h,000h,0C6h,0D6h,0FEh,0FEh,0EEh,044h,000h,000h
	DB	000h,000h,0C6h,06Ch,038h,038h,06Ch,0C6h,000h,000h
	DB	000h,000h,0CCh,0CCh,0CCh,07Ch,00Ch,0CCh,078h,000h
	DB	000h,000h,0FCh,098h,030h,060h,0C4h,0FCh,000h,000h
	DB	000h,01Ch,030h,030h,0E0h,030h,030h,01Ch,000h,000h
	DB	000h,018h,018h,018h,000h,018h,018h,018h,000h,000h
	DB	000h,0E0h,030h,030h,01Ch,030h,030h,0E0h,000h,000h
	DB	000h,076h,0DCh,000h,000h,000h,000h,000h,000h,000h
	DB	000h,000h,010h,038h,06Ch,0C6h,0C6h,0FEh,000h,000h
	DB	000h,000h,000h,000h,03Eh,060h,0C0h,060h,03Eh,008h
	DB	000h,000h,048h,000h,0CCh,0CCh,0CCh,0CCh,076h,000h
	DB	000h,018h,020h,000h,078h,0CCh,0FCh,0C0h,078h,000h
	DB	030h,048h,084h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h
	DB	048h,048h,000h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h
	DB	060h,010h,000h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h
	DB	048h,030h,000h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h
	DB	000h,000h,000h,078h,0CCh,0C0h,0C0h,0CCh,078h,010h
	DB	030h,048h,084h,078h,0CCh,0FCh,0C0h,0CCh,078h,000h
	DB	000h,048h,000h,078h,0CCh,0FCh,0C0h,0CCh,078h,000h
	DB	060h,010h,000h,078h,0CCh,0FCh,0C0h,0CCh,078h,000h
	DB	000h,048h,000h,070h,030h,030h,030h,030h,078h,000h
	DB	030h,048h,000h,070h,030h,030h,030h,030h,078h,000h
	DB	060h,010h,000h,070h,030h,030h,030h,030h,078h,000h
	DB	048h,000h,030h,078h,0CCh,0CCh,0FCh,0CCh,0CCh,000h
	DB	030h,048h,030h,048h,084h,0FCh,084h,084h,084h,000h
	DB	018h,020h,000h,0F8h,080h,0F0h,080h,080h,0F8h,000h
	DB	000h,000h,000h,066h,099h,01Fh,078h,099h,0F7h,000h
	DB	000h,000h,000h,00Fh,014h,027h,07Ch,084h,087h,000h
	DB	030h,048h,084h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h
	DB	000h,048h,000h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h
	DB	060h,010h,000h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h
	DB	030h,048h,084h,000h,0CCh,0CCh,0CCh,0CCh,076h,000h
	DB	060h,010h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h
	DB	048h,000h,0CCh,0CCh,0CCh,0CCh,07Ch,00Ch,08Ch,078h
	DB	044h,000h,038h,06Ch,0C6h,0C6h,0C6h,06Ch,038h,000h
	DB	024h,000h,066h,066h,066h,066h,066h,066h,03Ch,000h
	DB	000h,030h,078h,0CCh,0C0h,0C0h,0CCh,078h,030h,000h
	DB	01Ch,022h,020h,070h,020h,020h,022h,05Ch,000h,000h
	DB	082h,044h,028h,010h,010h,07Ch,010h,07Ch,010h,000h
	DB	0F0h,088h,08Ah,0F7h,082h,082h,082h,083h,000h,000h
	DB	006h,009h,008h,008h,03Ch,010h,010h,090h,060h,000h
	DB	018h,020h,000h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h
	DB	018h,020h,000h,070h,030h,030h,030h,030h,078h,000h
	DB	018h,020h,000h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h
	DB	018h,020h,000h,0CCh,0CCh,0CCh,0CCh,0CCh,076h,000h
	DB	080h,0F8h,004h,0FCh,0CCh,0CCh,0CCh,0CCh,0CCh,000h
	DB	080h,0FEh,001h,0C6h,0E6h,0D6h,0CEh,0C6h,0C6h,000h
	DB	000h,078h,00Ch,07Ch,0CCh,0CCh,076h,000h,0FEh,000h
	DB	000h,078h,0CCh,0CCh,0CCh,0CCh,078h,000h,0FCh,000h
	DB	018h,000h,018h,018h,018h,030h,060h,066h,03Ch,000h
	DB	0FFh,080h,080h,080h,080h,000h,000h,000h,000h,000h
	DB	0FFh,001h,001h,001h,001h,000h,000h,000h,000h,000h
	DB	040h,0C4h,048h,050h,026h,049h,082h,007h,000h,000h
	DB	040h,0C4h,048h,050h,026h,04Ah,09Fh,002h,000h,000h
	DB	000h,030h,000h,070h,030h,030h,030h,030h,078h,000h
	DB	000h,012h,024h,048h,090h,048h,024h,012h,000h,000h
	DB	000h,048h,024h,012h,009h,012h,024h,048h,000h,000h
	DB	000h,049h,000h,092h,000h,049h,000h,092h,000h,049h
	DB	000h,06Dh,000h,0B6h,000h,06Dh,000h,0B6h,000h,06Dh
	DB	055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh,055h,0AAh
	DB	010h,010h,010h,010h,010h,010h,010h,010h,010h,010h
	DB	010h,010h,010h,010h,010h,0F0h,010h,010h,010h,010h
	DB	010h,010h,010h,010h,0F0h,010h,0F0h,010h,010h,010h
	DB	028h,028h,028h,028h,028h,0E8h,028h,028h,028h,028h
	DB	000h,000h,000h,000h,000h,0F8h,028h,028h,028h,028h
	DB	000h,000h,000h,000h,0F0h,010h,0F0h,010h,010h,010h
	DB	028h,028h,028h,028h,0E8h,008h,0E8h,028h,028h,028h
	DB	028h,028h,028h,028h,028h,028h,028h,028h,028h,028h
	DB	000h,000h,000h,000h,0F8h,008h,0E8h,028h,028h,028h
	DB	028h,028h,028h,028h,0E8h,008h,0F8h,000h,000h,000h
	DB	028h,028h,028h,028h,028h,0F8h,000h,000h,000h,000h
	DB	010h,010h,010h,010h,0F0h,010h,0F0h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,0F0h,010h,010h,010h,010h
	DB	010h,010h,010h,010h,010h,01Fh,000h,000h,000h,000h
	DB	010h,010h,010h,010h,010h,0FFh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,0FFh,010h,010h,010h,010h
	DB	010h,010h,010h,010h,010h,01Fh,010h,010h,010h,010h
	DB	000h,000h,000h,000h,000h,0FFh,000h,000h,000h,000h
	DB	010h,010h,010h,010h,010h,0FFh,010h,010h,010h,010h
	DB	010h,010h,010h,010h,01Fh,010h,01Fh,010h,010h,010h
	DB	028h,028h,028h,028h,028h,03Fh,028h,028h,028h,028h
	DB	028h,028h,028h,028h,02Fh,020h,03Fh,000h,000h,000h
	DB	000h,000h,000h,000h,03Fh,020h,02Fh,028h,028h,028h
	DB	028h,028h,028h,028h,0EFh,000h,0FFh,000h,000h,000h
	DB	000h,000h,000h,000h,0FFh,000h,0EFh,028h,028h,028h
	DB	028h,028h,028h,028h,02Fh,020h,02Fh,028h,028h,028h
	DB	000h,000h,000h,000h,0FFh,000h,0FFh,000h,000h,000h
	DB	028h,028h,028h,028h,0EFh,000h,0EFh,028h,028h,028h
	DB	010h,010h,010h,010h,0FFh,000h,0FFh,000h,000h,000h
	DB	028h,028h,028h,028h,028h,0FFh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0FFh,000h,0FFh,010h,010h,010h
	DB	000h,000h,000h,000h,000h,0FFh,028h,028h,028h,028h
	DB	028h,028h,028h,028h,028h,03Fh,000h,000h,000h,000h
	DB	010h,010h,010h,010h,01Fh,010h,01Fh,000h,000h,000h
	DB	000h,000h,000h,000h,01Fh,010h,01Fh,010h,010h,010h
	DB	000h,000h,000h,000h,000h,03Fh,028h,028h,028h,028h
	DB	028h,028h,028h,028h,028h,0FFh,028h,028h,028h,028h
	DB	010h,010h,010h,010h,0FFh,010h,0FFh,010h,010h,010h
	DB	010h,010h,010h,010h,010h,0F0h,000h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,01Fh,010h,010h,010h,010h
	DB	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	DB	000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh
	DB	0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h
	DB	007h,007h,007h,007h,007h,007h,007h,007h,007h,007h
	DB	0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h
	DB	000h,000h,000h,036h,04Ch,048h,048h,04Ch,036h,000h
	DB	05Ch,022h,022h,03Ch,044h,044h,078h,080h,080h,000h
	DB	0FEh,042h,040h,040h,040h,040h,040h,040h,0E0h,000h
	DB	000h,000h,000h,07Ch,028h,028h,028h,028h,028h,000h
	DB	07Eh,061h,030h,018h,008h,010h,030h,061h,07Eh,000h
	DB	000h,000h,000h,07Fh,0CCh,0CCh,0CCh,0CCh,078h,000h
	DB	000h,000h,048h,048h,048h,048h,074h,040h,0C0h,000h
	DB	000h,000h,000h,07Ch,010h,010h,010h,010h,000h,000h
	DB	01Ch,008h,03Eh,041h,041h,041h,03Eh,008h,01Ch,000h
	DB	018h,024h,066h,066h,07Eh,066h,066h,024h,018h,000h
	DB	03Ch,066h,0C3h,0C3h,0C3h,066h,024h,0A5h,0E7h,000h
	DB	00Ch,012h,010h,008h,01Ch,022h,022h,022h,01Ch,000h
	DB	000h,000h,000h,000h,000h,06Ch,092h,092h,06Ch,000h
	DB	000h,000h,001h,01Ah,026h,02Ah,032h,02Ch,040h,000h
	DB	03Ch,060h,060h,060h,078h,060h,060h,060h,03Ch,000h
	DB	000h,000h,000h,000h,018h,018h,000h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	DB	000h,000h,000h,000h,000h,00Eh,00Eh,00Eh,00Eh,000h
	DB	00Eh,00Eh,00Eh,00Eh,000h,00Eh,00Eh,00Eh,00Eh,000h
	DB	000h,000h,000h,000h,000h,0E0h,0E0h,0E0h,0E0h,000h
	DB	000h,000h,000h,000h,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	00Eh,00Eh,00Eh,00Eh,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	0E0h,0E0h,0E0h,0E0h,000h,0E0h,0E0h,0E0h,0E0h,000h
	DB	0E0h,0E0h,0E0h,0E0h,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	0EEh,0EEh,0EEh,0EEh,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	040h,0E0h,040h,040h,000h,0E0h,0E0h,0E0h,0E0h,000h
	DB	040h,0E0h,040h,040h,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	04Eh,0EEh,04Eh,04Eh,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	044h,0EEh,044h,044h,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	004h,00Eh,004h,004h,000h,00Eh,00Eh,00Eh,00Eh,000h
	DB	004h,00Eh,004h,004h,000h,0EEh,0EEh,0EEh,0EEh,000h
	DB	0E4h,0EEh,0E4h,0E4h,000h,0EEh,0EEh,0EEh,0EEh,000h

;-------------------------------------------------------------------------------

offset_current_page:
	DW	OFFSET edid_message_01,OFFSET edid_01
	DW	OFFSET edid_message_02,OFFSET edid_02
	DW	OFFSET edid_message_03,OFFSET edid_03
	DW	OFFSET edid_message_04,OFFSET edid_04
	DW	OFFSET edid_message_05,OFFSET edid_05
	DW	OFFSET edid_message_06,OFFSET edid_06
	DW	OFFSET edid_message_07,OFFSET edid_07
	DW	OFFSET edid_message_08,OFFSET edid_08
	DW	OFFSET edid_message_09,OFFSET edid_09
end_offset_current_page:

edid3_routine:
	DW	OFFSET edid_3_1
	DW	OFFSET edid_3_2
	DW	OFFSET edid_3_3
	DW	OFFSET edid_3_4
table_ar:
	DB	10d,16d
	DB	3d,4d
	DB	4d,5d
	DB	9d,16d
table_edid_rate:
	DB	0h,0h,0h,0h,0h
	DB	2h,0h,0FFh,0h,0h
	DB	3h,0FFh,0FFh,0h,0h
	DB	8h,0h,0FFh,0h,0h
	DB	0Ah,0h,0FFh,0h,0FFh
	DB	0Bh,0h,0FFh,0FFh,0FFh
	DB	0Ch,0FFh,0FFh,0h,0h
	DB	0Eh,0FFh,0FFh,0h,0FFh
	DB	0Fh,0FFh,0FFh,0FFh,0FFh
table_edid_color:
	DB	7h,2h
	DB	8h,0h
table_ar_cvt:
	DB	4d,3d
	DB	16d,9d
	DB	16d,10d
	DB	15d,9d
end_table_ar_cvt:

;-------------------------------------------------------------------------------

x_vesa_name:
	DB	'X-VESA.COM'
end_x_vesa_name:

vesa_mode_table:
	VESA_MODE_1X <100h, 640d, 400d, 8d, 4d>
	VESA_MODE_1X <101h, 640d, 480d, 8d, 4d>
	VESA_MODE_1X <103h, 800d, 600d, 8d, 4d>
	VESA_MODE_1X <105h, 1024d, 768d, 8d, 4d>
	VESA_MODE_1X <107h, 1280d, 1024d, 8d, 4d>
	VESA_MODE_1X <102h, 800d, 600d, 4d, 3d>
	VESA_MODE_1X <104h, 1024d, 768d, 4d, 3d>
	VESA_MODE_1X <106h, 1280d, 1024d, 4d, 3d>
	VESA_MODE_1X <108h, 80d, 60d, 4d, 0d>
	VESA_MODE_1X <109h, 132d, 25d, 4d, 0d>
	VESA_MODE_1X <10Ah, 132d, 43d, 4d, 0d>
	VESA_MODE_1X <10Bh, 132d, 50d, 4d, 0d>
	VESA_MODE_1X <10Ch, 132d, 60d, 4d, 0d>
end_vesa_mode_table:

table_vesa_commands:
	DW	OFFSET VESA_Command_01,OFFSET VESA_Command_02,OFFSET VESA_Command_03
	DW	OFFSET VESA_Command_04,OFFSET VESA_Command_05,OFFSET VESA_Command_06
	DW	OFFSET VESA_Command_07,OFFSET VESA_Command_08,OFFSET VESA_Command_09
end_table_vesa_commands:

set_bank_routine:
	DW	OFFSET Set_Bank_Int10_WinA_RW
	DW	OFFSET Set_Bank_Int10_WinB_RW
	DW	OFFSET Set_Bank_Int10_WinA_RoW_WinB_RoW
	DW	OFFSET set_bank_Call_WinA_RW
	DW	OFFSET set_bank_Call_WinB_RW
	DW	OFFSET set_bank_Call_WinA_RoW_WinB_RoW
default_direct_color_mask:
	DB	5h,0Ah,5h,5h,5h,0h
	DB	5h,0Bh,5h,6h,5h,0h
	DB	8h,10h,8h,8h,8h,0h

vesa_speed_routines:
	DW	OFFSET R_008B,OFFSET W_008B
	DW	OFFSET R_016B,OFFSET W_016B
	DW	OFFSET R_032B,OFFSET W_032B
	DW	OFFSET R_064B,OFFSET W_064B
	DW	OFFSET R_128B,OFFSET W_128B
	DW	OFFSET R_256B,OFFSET W_256B
	DW	OFFSET R_512B,OFFSET W_512B
	DW	OFFSET R_008L,OFFSET W_008L
	DW	OFFSET R_016L,OFFSET W_016L
	DW	OFFSET R_032L,OFFSET W_032L
	DW	OFFSET R_064L,OFFSET W_064L
	DW	OFFSET R_128L,OFFSET W_128L
	DW	OFFSET R_256L,OFFSET W_256L
	DW	OFFSET R_512L,OFFSET W_512L
	DW	OFFSET dummy_R_008B,OFFSET dummy_W_008B
	DW	OFFSET dummy_R_016B,OFFSET dummy_W_016B
	DW	OFFSET dummy_R_032B,OFFSET dummy_W_032B
	DW	OFFSET dummy_R_064B,OFFSET dummy_W_064B
	DW	OFFSET dummy_R_128B,OFFSET dummy_W_128B
	DW	OFFSET dummy_R_256B,OFFSET dummy_W_256B
	DW	OFFSET dummy_R_512B,OFFSET dummy_W_512B
	DW	OFFSET dummy_R_008L,OFFSET dummy_W_008L
	DW	OFFSET dummy_R_016L,OFFSET dummy_W_016L
	DW	OFFSET dummy_R_032L,OFFSET dummy_W_032L
	DW	OFFSET dummy_R_064L,OFFSET dummy_W_064L
	DW	OFFSET dummy_R_128L,OFFSET dummy_W_128L
	DW	OFFSET dummy_R_256L,OFFSET dummy_W_256L
	DW	OFFSET dummy_R_512L,OFFSET dummy_W_512L
end_vesa_speed_routines:

start_patterns_single:
	DD	00000000000000000000000000000000b
	DD	00010001000100010001000100010001b
	DD	00100010001000100010001000100010b
	DD	00110011001100110011001100110011b
	DD	01000100010001000100010001000100b
	DD	01010101010101010101010101010101b
	DD	01100110011001100110011001100110b
	DD	01110111011101110111011101110111b
	DD	10001000100010001000100010001000b
	DD	10011001100110011001100110011001b
	DD	10101010101010101010101010101010b
	DD	10111011101110111011101110111011b
	DD	11001100110011001100110011001100b
	DD	11011101110111011101110111011101b
	DD	11101110111011101110111011101110b
	DD	11111111111111111111111111111111b
end_patterns_single:

start_patterns_multi:
	DD	0F0F0F0Fh
	DD	1E1E1E1Eh
	DD	2D2D2D2Dh
	DD	3C3C3C3Ch
	DD	4B4B4B4Bh
	DD	5A5A5A5Ah
	DD	69696969h
	DD	78787878h
	DD	87878787h
	DD	96969696h
	DD	0A5A5A5A5h
	DD	0B4B4B4B4h
	DD	0C3C3C3C3h
	DD	0D2D2D2D2h
	DD	0E1E1E1E1h
	DD	0F0F0F0F0h
end_patterns_multi:

;-------------------------------------------------------------------------------

decimal_sign:
	DB	'.'
thousands_sign:
	DB	','
n_digit_str_dec:
	DB	4h
color_base_mem:
	DB	COLOR_BASE
status_flag_0:
	DB	0h
status_flag_1:
	DB	0h
status_flag_2:
	DB	0h
status_flag_3:
	DB	0h
status_flag_4:
	DB	0h
status_flag_5:
	DB	0h
status_flag_6:
	DB	0h
n_saved_video_page:
	DB	0h
n_edid_controller:
	DB	0h
bit_table:
	DB	0h,1h,1h,2h,1h,2h,2h,3h,1h,2h,2h,3h,2h,3h,3h,4h
led_table:
	DB	20h,40h,10h,40h
table_dac_offset_string:
	DB	4h * VIDEO_FONT_WIDTH,6h * VIDEO_FONT_WIDTH,5h * VIDEO_FONT_WIDTH,5h * VIDEO_FONT_WIDTH
dual_key_table:
	DW	UP_KEY2,UP_KEY
	DW	DOWN_KEY2,DOWN_KEY
	DW	LEFT_KEY2,LEFT_KEY
	DW	RIGHT_KEY2,RIGHT_KEY
	DW	HOME_KEY2,HOME_KEY
	DW	END_KEY2,END_KEY
	DW	PGUP_KEY2,PGUP_KEY
	DW	PGDN_KEY2,PGDN_KEY
	DW	ENTER_KEY2,ENTER_KEY
	DW	INS_KEY2,INS_KEY
	DW	DEL_KEY2,DEL_KEY
	DW	_1_KEY2,_1_KEY
	DW	_2_KEY2,_2_KEY
	DW	_3_KEY2,_3_KEY
	DW	_4_KEY2,_4_KEY
	DW	CTRL_LEFT_KEY2,CTRL_LEFT_KEY
	DW	CTRL_RIGHT_KEY2,CTRL_RIGHT_KEY
	DW	PLUS_KEY2,PLUS_KEY
	DW	MINUS_KEY2,MINUS_KEY
	DW	CTRL_UP_KEY2,CTRL_UP_KEY
	DW	CTRL_DOWN_KEY2,CTRL_DOWN_KEY
end_dual_key_table:

;-------------------------------------------------------------------------------

panel_01:
	PANEL < (PANEL_BORDER SHL 8h) + WINDOW_INFO_Y + PANEL1_INTESTATION_Y + 1h, 
		TEXT_WIDTH - (PANEL_BORDER SHL 1h),
		INVERSION_COLOR,
		OFFSET Write_Panel_01,
		((TEXT_WIDTH - 1h) SHL 8h) + WINDOW_INFO_Y + PANEL1_INTESTATION_Y + 1h,
		ZERO_VESA_MODE,
		0h,
		TEXT_HEIGHT - WINDOW_INFO_Y - PANEL1_INTESTATION_Y - PANEL_BORDER - 1h,
		0h,
		TEXT_HEIGHT - WINDOW_INFO_Y - PANEL1_INTESTATION_Y - (PANEL_BORDER SHL 1h) - 1h,
		0h >
panel_02:
	PANEL < (((TEXT_WIDTH - EDID_INVERT_LEN) SHR 1h) SHL 8h),
		EDID_INVERT_LEN,
                INVERSION_COLOR,
		OFFSET Write_Panel_02,
		?,
		0h,
		0h,
		0h,
		0h,
		?,
		1h >
panel_03:
	PANEL <	(((TEXT_WIDTH - COMMANDS_INVERT_LEN) SHR 1h) SHL 8h) + ((TEXT_HEIGHT - TOTAL_VESA_COMMANDS - 4h) SHR 1h) - 4h,
		COMMANDS_INVERT_LEN,
		INVERSION_COLOR,
		OFFSET Write_Panel_03,
		((((TEXT_WIDTH - COMMANDS_BOX_LEN) SHR 1h) + COMMANDS_BOX_LEN - 1h) SHL 8h) + ((TEXT_HEIGHT - TOTAL_VESA_COMMANDS - 4h) SHR 1h) - 5h,
		TOTAL_VESA_COMMANDS - 1h,
		0h,
		TOTAL_VESA_COMMANDS - 1h,
		0h,
		TOTAL_VESA_COMMANDS - 1h,
		1h >
panel_04:
	PANEL <	200h + MAIN_WIN1_HEIGHT + 5h,
		REPORT_INVERT_LEN,
		INVERSION_COLOR,
		OFFSET Write_Panel_04,
		((TEXT_WIDTH - 1h) SHL 8h) + MAIN_WIN1_HEIGHT + 5h,
		?,
		0h,
		TEXT_HEIGHT - MAIN_WIN1_HEIGHT - 7h,
		0h,
		TEXT_HEIGHT - MAIN_WIN1_HEIGHT - 9h,
		0h >
panel_05:
	PANEL < (PANEL_BORDER SHL 8h) + WINDOW_INFO_Y + PANEL1_INTESTATION_Y + 1h, 
		TEXT_WIDTH - (PANEL_BORDER SHL 1h),
		INVERSION_COLOR,
		OFFSET Write_Panel_05,
		((TEXT_WIDTH - 1h) SHL 8h) + WINDOW_INFO_Y + PANEL1_INTESTATION_Y + 1h,
		ZERO_VESA_MODE,
		0h,
		TEXT_HEIGHT - WINDOW_INFO_Y - PANEL1_INTESTATION_Y - PANEL_BORDER - 1h,
		0h,
		TEXT_HEIGHT - WINDOW_INFO_Y - PANEL1_INTESTATION_Y - (PANEL_BORDER SHL 1h) - 1h,
		0h >
panel_06:
	PANEL < ((((TEXT_WIDTH - VRES_PANEL_WIDHT) SHR 1h) + 2h) SHL 8h ) + 4d,
		VRES_PANEL_WIDHT - 4d,
		INVERSION_COLOR,
		OFFSET Write_Panel_06,
		((((TEXT_WIDTH - VRES_PANEL_WIDHT) SHR 1h) + VRES_PANEL_WIDHT - 1d) SHL 8h) + 1d,
		?,
		0h,
		TEXT_HEIGHT - 7d,
		0h,
		TEXT_HEIGHT - 5d,
		0h >
panel_07:
	PANEL < ((((TEXT_WIDTH - 36d) SHR 1h) + 2h) SHL 8h ) + 18d,
		32d,
		INVERSION_COLOR,
		OFFSET Write_Panel_07,
		?,
		3d,
		0h,
		3d,
		0h,
		?,
		1h >

;-------------------------------------------------------------------------------

inputs_01:
	INPUTS < 2913h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_1,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit,
		 ?,? >
inputs_02:
	INPUTS < 2012h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_2,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit,
		 ?,? >
inputs_03:
	INPUTS < 2013h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_3,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit,
		 ?,? >
inputs_04:
	INPUTS < 2014h,
		 BIN_COLOR,
		 2h,
		 OFFSET Choice_Verify_4,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit,
		 ?,? >
inputs_05:
	INPUTS < 2116h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_5,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit_01,
		 ?,? >
inputs_06:
	INPUTS < 2D12h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_5,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit_02,
		 ?,? >
inputs_07:
	INPUTS < 2D13h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_5,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit_03,
		 ?,? >
inputs_08:
	INPUTS < 2D14h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_5,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit_04,
		 ?,? >
inputs_09:
	INPUTS < 2D15h,
		 BIN_COLOR,
		 ?,
		 OFFSET Choice_Verify_5,
		 OFFSET input_buffer,
		 ?,
		 OFFSET tmp_input_buffer,
		 OFFSET Choice_Exit_05,
		 ?,? >

;-------------------------------------------------------------------------------

iff_pbm_data:
	IFF_PBM < 'FORM',
		  ?,
		  'PBM ',
		  'BMHD',
		  14000000h,
		  ?,
		  ?,
		  0h,
		  0h,
	 	  ?,
		  0h,
		  1h,
		  0h,
		  0h,
		  1h,
		  1h,
		  ?,
		  ? >
iff_cmap_data:
	IFF_CMAP < 'CMAP',
		  ? >
iff_body_data:
	IFF_BODY < 'BODY',
		  ? >

;-------------------------------------------------------------------------------

edid_header:
	DB	0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0h

;-------------------------------------------------------------------------------

	ALIGN 8h

GDT_Start:
	DW	0h,0h,0h,0h	
	DW	0FFFFh
	DW	0h
	DB	0h
	DB	10010010b
	DB	11001111b
	DB	0h
GDT_End:

GDT_Ptr:
	DW	OFFSET GDT_End - OFFSET GDT_Start - 1h
GDT_Addr:
	DD	0h

;-------------------------------------------------------------------------------

dos_message_pointer:
	DW	?
decimal_digits:
	DB	?
number_count:
	DB	?
current_edid_page:
	DB	?
n_line_help:
	DB	?
string_id:
	DB	?
vbepm_capabilities:
	DB	?
start_xy:
	DW	?
key_status:
	DW	?
offset_pmid:
	DW	?
segment_pmid:
	DW	?
offset_pm0a:
	DW	?
segment_pm0a:
	DW	?
iff_write_bytes:
	DD	?
dc_red_size:
	DB	?
dc_red_pos:
	DB	?
dc_green_size:
	DB	?
dc_green_pos:
	DB	?
dc_blue_size:
	DB	?
dc_blue_pos:
	DB	?
set_bank_default:
	DW	?
granularity_units_per_bank:
	DW	?
banked_segment:
	DW	?
segment_size:
	DW	?
current_bpsl:
	DW	?
current_bank:
	DW	?
segment_bound:
	DD	?
current_call_vesa_pointer:
	DD	?
current_linear_vram_address:
	DD	?
timer_start:
	DD	?
elapsed_time:
	DD	?
timer_overhead:
	DD	?
kb_proc:
	DD	?
timer_ticks:
	DD	?
n_exec_test:
	DD	?
current_page_result:
	DB	?
vertical_refresh:
	DD	?
horizontal_refresh:
	DD	?
bandwidth:
	DD	?
tmp_vram_offset:
	DD	?
tmp_vram_size:
	DD	?
valid_sample_hor:
	DW	?
old_status_led:
	DB	?
offset_led_table:
	DW	?
sm_val:
	DD	?
shift_font:
	DB	?
str_len_vesa:
	DW	?
line_font:
	DW	?
init_string:
	DW	?
text_vesa_color:
	DB	?
foreground_vesa_color:
	DD	?
background_vesa_color:
	DD	?
vesa_char_string:
	DW	?
last_sec_time:
	DW	?
last_nomad_pos:
	DD	?
n_pass:
	DB	?
tmp_n_pass:
	DB	?
n_vram_errors:
	DW	?
test_type:
	DB	?
current_font_scanline:
	DB	?
current_font_scanrow:
	DB	?
command_box_x_start:
	DW	?
command_box_x_end:
	DW	?
command_box_x_len:
	DW	?
command_box_y_start:
	DW	?
command_box_y_end:
	DW	?
command_box_y_len:
	DW	?
vesa_direct_color:
	DD	?
current_bpl:
	DD	?
quotient:
	DB	?
extra_div:
	DD	?
rstss:
	DD	?
current_green_val:
	DB	?
error_open_vesa_video_mode:
	DB	?
max_di_bank:
	DW	?
scanline_vesa_pixel:
	DW	?
scanline_vesa_bytes:
	DW	?
fpu_test:
	DW	?
fail_hor_samples:
	DW	?
min_pit_hor:
	DD	?
distr_zoom:
	DW	?
distr_shift:
	DW	?
fo_pit:
	DW	?
max_fo:
	DD	?
min_fo:
	DD	?
max_fo_tmp:
	DD	?
min_fo_tmp:
	DD	?
max_samples:
	DW	?
max_samples_tmp:
	DW	?
n_samples_fo:
	DW	?
current_retrace:
	DB	?
old_retrace:
	DB	?
retrace_box_y:
	DW	?,?
retrace_box_x:
	DW	?,?,?,?,?,?
n_scanline:
	DW	?
virtual_x_res:
	DW	?
virtual_y_res:
	DW	?
offset_virtual_x_res:
	DW	?
offset_virtual_y_res:
	DW	?
old_offset_int_00:
	DW	?
old_segment_int_00:
	DW	?
color_base_mem_tmp:
	DB	?
color_string_dac:
	DW	?
dac_6_8_coords:
	DW	?,?,?,?,?,?,?,?
dac_6_8_offset:
	DW	?
vesa_single_palette_color:
	DD	?
clear_value:
	DD	?
min_virtual_hor:
	DW	?
max_virtual_hor:
	DW	?
min_virtual_ver:
	DW	?
max_virtual_ver:
	DW	?
ds_align_x:
	DB	?
ds_align_y:
	DB	?
ds_bound_x:
	DW	?
ds_bound_y:
	DW	?
vbios_size:
	DB	?

;-------------------------------------------------------------------------------

result_speed:
	DD	(TEST_NUMBER SHL 2h) DUP (?)
end_result_speed:

x_vesa_file_name:
	DB	(DOS_MAX_LEN_PATH + 1) DUP (?)
vesa_mode_info:
	VESA_MODE_PANEL MAX_VESA_MODE DUP (<>)
edid_data:
	EDID MAX_EDID_CONTROLLERS DUP (<>)
vesa_buffer_func_0:
	VbeInfoBlock <>
vesa_buffer_func_1:
	ModeInfoBlock <>
dos_create_file:
	CREATE_FILE <>
vesa_line:
	LINE <>
vesa_box:
	VBOX <>
little_vesa_box:
	VBOX <>
edid_extension_buffer:
	DB	(SIZEOF EDID128) DUP (?)
input_buffer:
	DB	MAX_INPUT_BUFFER DUP (?)
tmp_input_buffer:
	DB	MAX_INPUT_BUFFER DUP (?)
default_register_80x40:
	DB	N_REGS_80x40 DUP (?)
dos_country_info_buffer:
	DB	DOS_COUNTRY_INFO_BUFFER_LEN DUP (?)
iff_buffer:
	DB	MAX_IFF_BUFFER DUP (?)
dc_24_12_color:
	DD	3h DUP (?)
distribution_data:
	DW	N_DISTR_DATA DUP (?)

	ALIGN	10h

buffer_vesa_string:
	DB	((TEXT_WIDTH + 10h) SHL 1h) DUP (?)
end_data:

;-------------------------------------------------------------------------------

	DATA ENDS
