VbeInfoBlock STRUC
	VbeSignature		DB 4d DUP (?)
	VbeVersion		DW ?
	OemStringPtr		DD ?
	Capabilities		DB 4d DUP (?)
	VideoModePtr		DD ?
	TotalMemory		DW ?
	OemSoftwareRev		DW ?
	OemVendorNamePtr        DD ?
	OemProductNamePtr	DD ?
	OemProductRevPtr	DD ?
	Reserved1		DB 222d DUP (?)
	OemData			DB 256d DUP (?)
VbeInfoBlock ENDS

ModeInfoBlock STRUC
	ModeAttributes 		DW ?
	WinAAttributes		DB ?
	WinBAttributes		DB ?
	WinGranularity		DW ?
	WinSize			DW ?
	WinASegment		DW ?
	WinBSegment		DW ?
	WinFuncPtr		DD ?
	BytesPerScanLine	DW ?
	XResolution		DW ?
	YResolution		DW ?
	XCharSize		DB ?
	YCharSize		DB ?
	NumberOfPlanes		DB ?
	BitsPerPixel		DB ?
	NumberOfBanks		DB ?
	MemoryModel		DB ?
	BankSize		DB ?
	NumberOfImagePages	DB ?
	Reserved2		DB ?
	RedMaskSize		DB ?
	RedFieldPosition	DB ?
	GreenMaskSize		DB ?
	GreenFieldPosition	DB ?
	BlueMaskSize		DB ?
	BlueFieldPosition	DB ?
	RsvdMaskSize		DB ?
	RsvdFieldPosition	DB ?
	DirectColorModeInfo	DB ?
	PhysBasePtr		DD ?
	OffScreenMemOffset	DD ?
	OffScreenMemSize	DW ?
	LinBytesPerScanLine	DW ?
	BnkNumberOfImagePages	DB ?
	LinNumberOfImagePages	DB ?
	LinRedMaskSize		DB ?
	LinRedFieldPosition	DB ?
	LinGreenMaskSize	DB ?
	LinGreenFieldPosition	DB ?
	LinBlueMaskSize		DB ?
	LinBlueFieldPosition	DB ?
	LinRsvdMaskSize		DB ?
	LinRsvdFieldPosition	DB ?
	MaxPixelClock		DD ?
	Reserved3		DB 189d dup (?)
ModeInfoBlock ENDS

PMInfoBlock STRUC
	Signature		DB 4 DUP (?)
	EntryPoint		DW ?
	PMInitialize		DW ?
	BIOSDataSel		DW ?
	A0000Sel		DW ?
	B0000Sel		DW ?
	B8000Sel		DW ?
	CodeSegSel		DW ?
	InProtectMode		DB ?
	Checksum		DB ?
PMInfoBlock ENDS

EDID128 STRUC
	Header			DB 8h DUP (?)
	ManufacturerID		DW ?
	ProductID       	DW ?
	SerialNumber		DD ?
	MfgWeek			DB ?
	MfgYear		        DB ?
	EdidVersion     	DB ?
	EdidRevision    	DB ?
	VideoInput		DB ?
	MaxHSize        	DB ?
	MaxVSize        	DB ?
	Gamma			DB ?
	Features		DB ?
	ChromaData		DB 10 DUP (?)
	EstTimings		DB 3 DUP (?)
	StdTimings		DB 16 DUP (?)
	Desc1           	DB 18 DUP (?)
	Desc2           	DB 18 DUP (?)
	Desc3           	DB 18 DUP (?)
	Desc4           	DB 18 DUP (?)
	ExtensionFlag   	DB ?
	Checksum        	DB ?
EDID128 ENDS

IFF_PBM STRUC
	FORMID 			DB 4 DUP (?)
    	FileSize		DD ?     
	PBMID			DB 4 DUP (?)
	BMHD			DB 4 DUP (?)
	BMHDSize		DD ?
	Width			DW ?
	Height			DW ?
	CooX			DW ?
	CooY			DW ?
	nPlanes			DB ?
	masking			DB ?
	compression		DB ?
	pad1			DB ?
	tColor			DW ?
	aspectX			DB ?
	aspectY			DB ?
	pageWidth		DW ?
	pageHeight		DW ?
IFF_PBM ENDS

IFF_CMAP STRUC
	CMAP			DB 4 DUP (?)
	CMAPSize		DD ?
IFF_CMAP ENDS

IFF_BODY STRUC
	BODY			DB 4 DUP (?)
	BODYSize		DD ?
IFF_BODY ENDS

EDID STRUC
	EDIDController		DW ?
	EDIDFlag		DB ?
	EDIDTime		DB ?
	EDIDData		DB EDID_LEN DUP (?)
EDID ENDS

VESA_MODE_PANEL STRUC
	VIDEO_MODE		DW ?
	X_RES			DW ? 
	Y_RES			DW ? 
	VIDEO_SEGMENT		DW ? 
	COLOR_BPP		DB ? 
	MEMORY_BPP		DB ?
	WINDOW_SIZE		DB ?
	WINDOW_GRANULARITY	DB ?
	VIDEO_MODE_MODEL	DB ?
	VRAM_SIZE_BANKED	DD ?
	VRAM_SIZE_LINEAR	DD ?
VESA_MODE_PANEL ENDS

VESA_MODE_1X STRUC
	VIDEO_MODE		DW ?
	X_RES			DW ?
	Y_RES			DW ?
	BPP			DB ?
	MODEL			DB ?
VESA_MODE_1X ENDS

INPUTS STRUC
	COORD_START		DW ?
	COLOR			DB ?
	LEN			DB ?
	VERIFY			DW ?
	BUFFER			DW ?
	KEY			DW ?
	TMP_BUFFER		DW ?
	EXIT			DW ?
	CUR_POS			DB ?
	TMP_CUR_POS		DB ?
INPUTS ENDS	

PANEL STRUC
	COORD_START		DW ?
	INVERSION_LEN		DB ?
	INVERSION_COLOR		DB ?
	DRAW_OFFSET		DW ?
	COOR_BAR		DW ?
	TOTAL_ELEMENTS		DW ?
	ABSOLUTE_ELEMENT	DW ?
	TOTAL_RELATIVE_ELEMENTS	DB ?
	RELATIVE_ELEMENT	DB ?
	BAR_ELEMENTS		DB ?
	PANEL_FLAGS		DB ?
PANEL ENDS

ERROR_VESA STRUC
	TICKS			DD ?
	OFFSET_VRAM		DD ?
	WRITE_VALUE		DD ?
	READ_VALUE		DD ?
	PASS			DB ?
	TEST_ID			DB ?
ERROR_VESA ENDS

CREATE_FILE STRUC
	OFFSET_INSTANT_MESSAGE	DW ?
	OFFSET_NAME_DECIMAL	DW ?
	OFFSET_FILE_NAME	DW ?
	OFFSET_FAIL_MESSAGE	DW ?
	OFFSET_CLOSE_MESSAGE	DW ?
	HANDLE_WRITE		DW ?
	BUFFER_LEN_IO		DW ?
	OFFSET_BUFFER_IO	DW ?
	SEGMENT_BUFFER_IO	DW ?
	DATA_LEN		DW ?
	OFFSET_BUFFER_SOURCE	DW ?
	SEGMENT_BUFFER_SOURCE	DW ?
CREATE_FILE ENDS

LINE STRUC
	X_POS			DW ?
	Y_POS			DW ?
	LEN			DW ?
LINE ENDS

VBOX STRUC
	X_START			DW ?
	Y_START			DW ?
	X_END			DW ?
	Y_END			DW ?
VBOX ENDS
