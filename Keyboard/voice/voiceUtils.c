#include <stdlib.h>
#include <stdio.h>
#include <memory.h>


extern const unsigned char arrayWavDataR[];

#define my_false            0
#define my_true             1


typedef unsigned char           MYBOOL;
typedef unsigned short  		Err;
typedef unsigned short			WChar;		// 'wide' int'l character type.
typedef signed short 			Coord;		// screen/window coordinate
typedef void *					MemPtr;		// global pointer

typedef struct
{
	unsigned int type;
	unsigned int size;
} ChunkHeader;

typedef struct
{
	ChunkHeader header;
} RiffChunk;

typedef struct
{
	ChunkHeader header;
	unsigned short      audioFormat;
	unsigned short      channels;
	unsigned int      sampleRate;
	unsigned int      avgByteRate;
	unsigned short      blockAlign;
	unsigned short      bitsPerSample;

} FmtSubChunk;

typedef struct
{
	unsigned short      size;
	unsigned short      samplesPerBlock;

} ExtraDataBlock;

typedef struct
{
	unsigned int      type;
	unsigned int      size;
} DataSubChunk;

typedef struct
{
	RiffChunk   riff;
	unsigned int      waveType;
	FmtSubChunk fmt;

} WaveHeader;

typedef struct
{
	WaveHeader      header;
	DataSubChunk    data; 
} WavePCM;
typedef struct
{
	unsigned int      type;
	unsigned int      size;
	unsigned int      samplesWritten;
} FactSubChunk;         // 12

typedef struct
{
	WaveHeader      header;
	ExtraDataBlock  extra;
    FactSubChunk    fact;
    DataSubChunk    data;

} WaveIMAADPCM;

#define	WAVE_TYPE_PCM			0x0001
#define	WAVE_TYPE_IMAADPCM		0x0011




#define	TYPE_RIFF	(('FFIR'))
#define	TYPE_WAVE	(('EVAW'))
#define	TYPE_FMT	((' tmf'))
#define	TYPE_DATA	(('atad'))

typedef signed short (*SearchFuncPtr)(const void *, const void *, unsigned long other);

// 头信息结构
typedef struct
{
	unsigned int  version;		// 版本号
	unsigned int  pyNum;			// 拼音个数
	unsigned int  format;			// 0 wav; 1 adpcm; 2 mp3;
	unsigned int  encrypt;		// 0 不加密, 1 rc4 加密	
	char    readme[256];	// 说明 如: 作者，日期等

	unsigned int  sampleRate;		// 8000/11025/16000/...
	unsigned int  channels;       // 声道数据 1 ~ 2
	unsigned int  sampleType;		// 采样精度 (如 : sndunsigned char)
   	unsigned int  blockAlign;		// Mostly there for ADPCM

}HeadInfoRecordType;


HeadInfoRecordType * g_head = 0;

typedef struct
{
    char    		py[6];
    unsigned char   tune;
}PyType;


typedef struct node
{
    PyType  py;
    unsigned char   padding;
    unsigned int  offset;

}TableEntry;

/*
void encode(unsigned char * inBuf, int bufSize, const char * key)
{
    struct rc4_state state;

    rc4_init(&state, (u_char*)key, strlen(key));
    rc4_crypt(&state, inBuf, inBuf, bufSize);
}
*/
/*
void ReadHead(FILE * fp, HeadInfoRecordType &head)
{
    fseek(fp, 0, SEEK_SET);
    
    fread(&head, 1, sizeof(head), fp);
}


TableEntry * ReadTable(FILE * fp, unsigned int *tableSize)
{
    TableEntry * tableP;
    
    fseek(fp, sizeof(HeadInfoRecordType), SEEK_SET);
    
    fread(tableSize, 1, sizeof(unsigned int), fp);
    tableP = (TableEntry*)malloc(*tableSize);
    
    fread(tableP, 1, *tableSize, fp);

    if (g_head.encrypt)
        encode((unsigned char*)tableP, *tableSize, "k&&^^%%*");

    return tableP;
}

**/

/***********************************************************************
 *
 * FUNCTION:    WritePCM_WAVEHeader
 *
 * DESCRIPTION: 写入 PCM 数据的头结构
 *
 * PARAMETERS:  fileStream  - 文件句柄
 *              waveDataP   - 头结构
 *
 * RETURNED:    Err
 *
 *  2006.07.23 - lzl
 *
 ***********************************************************************/
static int WritePCMHead(void * outData, int wavDataSize)
{
	WavePCM		pcm;
	int			err             = 0;
	int			numChannels     = g_head->channels;
	int			bitsPerSample   = g_head->sampleType*8;
	int			blockAlign      = numChannels * bitsPerSample / 8;
	int		    sampleRate		= g_head->sampleRate;
	
	// RIFF Header
	pcm.header.riff.header.type = TYPE_RIFF;    // "RIFF"标志
	pcm.header.riff.header.size	=  (sizeof(WavePCM) + wavDataSize - sizeof (ChunkHeader));   // 文件长度
	pcm.header.waveType			= TYPE_WAVE;    // "WAVE"标志
	
	// fmt sub-chunk
	pcm.header.fmt.header.type	= TYPE_FMT;     // "fmt"标志
	pcm.header.fmt.header.size	= (sizeof(FmtSubChunk) - sizeof(ChunkHeader));    // 过渡字节（不定）
	pcm.header.fmt.audioFormat	= (WAVE_TYPE_PCM);                          // 格式类别（10H为PCM形式的声音数据)
	pcm.header.fmt.channels		= (numChannels);                            // 通道数，单声道为1，双声道为2
	pcm.header.fmt.sampleRate	= (sampleRate);                  // 采样率（每秒样本数），表示每个通道的播放速度，
	pcm.header.fmt.avgByteRate	= (sampleRate * blockAlign);     // 波形音频数据传送速率，其值为通道数×每秒数据位数×每样本的数据位数／8。播放软件利用此值可以估计缓冲区的大小。
	pcm.header.fmt.blockAlign	= (blockAlign);                             // 数据块的调整数（按字节算的），其值为通道数×每样本的数据位值／8。播放软件需要一次处理多个该值大小的字节数据，以便将其值用于缓冲区的调整。
	pcm.header.fmt.bitsPerSample= (bitsPerSample);                          // 每样本的数据位数，表示每个声道中各个样本的数据位数。如果有多个声道，对每个声道而言，样本大小都一样。
	
	// data sub-chunk
	pcm.data.type				= TYPE_DATA;                                      // 数据标记符＂data＂
	pcm.data.size				= (wavDataSize);                   // 语音数据的长度	
	
	//  写入头
	//fseek(fp, 0, SEEK_SET);
	//fwrite(&pcm, 1, sizeof(pcm), fp);
	if (outData)
	{
		memmove(outData, &pcm, sizeof(pcm));
	}

Done:
	return err;
}
#define wave_format_dvi_adpcm 	        0x0011 	/* intel corporation */
#define wave_format_ima_adpcm 	        wave_format_dvi_adpcm 	/* intel corporation */
#define	TYPE_RIFF	(('FFIR'))
#define	TYPE_WAVE	(('EVAW'))
#define	TYPE_FMT	((' tmf'))
#define	TYPE_DATA	(('atad'))
#define	TYPE_FACT	(('tcaf'))

static int WriteADPCMHead(void * outData, int wavDataSize)
{
	WaveIMAADPCM adpcm;
	Err					err             = 0;
	unsigned short		numChannels     = 1;
	unsigned short 		bitsPerSample   = 4;	                    // ADPCM always encodes to 4-bit samples
	unsigned int   		samplesPerBlock = 0;
	unsigned short 		blockAlign      = 256;
	unsigned int      	sampleRate		= g_head->sampleRate;
	unsigned int 	    avgByteRate     = numChannels * sampleRate * bitsPerSample / 8;//通道数×每秒数据位数×每样本的数据位数／8    

	samplesPerBlock = ((blockAlign - (4 * numChannels)) * 8) / (bitsPerSample * numChannels) + 1;
	
	// RIFF Header
	adpcm.header.riff.header.type 	= TYPE_RIFF;                        // "RIFF"标志
	adpcm.header.riff.header.size	= (sizeof(WaveIMAADPCM) + wavDataSize - sizeof(ChunkHeader));  // 文件长度
	adpcm.header.waveType			= TYPE_WAVE;                        // "WAVE"标志
	
	// fmt sub-chunk
	adpcm.header.fmt.header.type	= TYPE_FMT;                         // "fmt"标志
	adpcm.header.fmt.header.size	= (sizeof(FmtSubChunk) - sizeof(ChunkHeader) + sizeof(ExtraDataBlock));//过渡字节（不定）
	adpcm.header.fmt.audioFormat	= (wave_format_ima_adpcm);    // 数据类型 (ADPCM/PCM)
	adpcm.header.fmt.channels		= (numChannels);              // 声道
	adpcm.header.fmt.sampleRate		= (sampleRate);               // 采样率（每秒样本数），表示每个通道的播放速度。
	adpcm.header.fmt.avgByteRate	= (avgByteRate);              // 波形音频数据传送速率，其值为通道数×每秒数据位数×每样本的数据位数／8。播放软件利用此值可以估计缓冲区的大小。
	adpcm.header.fmt.blockAlign		= (blockAlign);               // 数据块的调整数（按字节算的），其值为通道数×每样本的数据位值／8。播放软件需要一次处理多个该值大小的字节数据，以便将其值用于缓冲区的调整。
	adpcm.header.fmt.bitsPerSample	= (bitsPerSample);            // 每样本的数据位数，表示每个声道中各个样本的数据位数。如果有多个声道，对每个声道而言，样本大小都一样。
	
	adpcm.extra.size				= (sizeof(adpcm.extra.samplesPerBlock));
	adpcm.extra.samplesPerBlock		= (samplesPerBlock);
	
	// fact sub-chunk
	adpcm.fact.type                 = TYPE_FACT;                        // "fact"标志
	adpcm.fact.size                 = (sizeof(unsigned int));
	adpcm.fact.samplesWritten       = (wavDataSize / blockAlign * samplesPerBlock);
	
	// data sub-chunk
	adpcm.data.type					= TYPE_DATA;                          // 数据标记符＂data＂
	adpcm.data.size					= (wavDataSize);       // 语音数据的长度
	
	//  写入头
	//fseek(fp, 0, SEEK_SET);
	//fwrite(&adpcm, 1, sizeof(adpcm), fp);	
	if (outData)
	{
		memmove(outData, &adpcm, sizeof(adpcm));
	}

Done:
	return err;
}


void StrToPyType(const char * py, PyType *out)
{
    int len = (int)strlen(py);
    memset(out, 0, sizeof(PyType));

    if (len)
    {
        char endChar = py[len - 1];
        if (endChar >= '0' && endChar <= '9')
        {
            memmove((*out).py, py, len - 1);
            (*out).tune = (endChar - '0');
        }
        else
        {
            memmove((*out).py, py, len);
            (*out).tune = 0;
            //cout << "StrToPyType" << ">>"<<py <<endl;
        }
    }
}


/*********************************************************************************
 *
 *	函数名:		BinarySearch
 *
 *	功能说明:	二分查找函数
 *              Search elements in a sorted array for the specified data 
 *              according to the specified comparison function.
 *
 *	参数描述:	baseP           - Base pointer to an array of elements
 *              numOfElements   - Number of elements to search. Must be greater than 0.
 *              width           - Width of each array element.
 *              searchF         - Search function. 
 *              searchData      - Data to search for. This data is passed to the searchF function.
 *              other           - Data to be passed as the third parameter (the other parameter) to the comparison function.
 *              position        - Pointer to the position result.
 *              findFirst       - If set to true, the first matching element is returned. 
 *                                Use this parameter if the array contains duplicate entries to ensure 
 *                                that the first such entry will be the one returned.
 *
 *	返回值:		Returns true if an exact match was found. In this case, position points to the element number where the data was found.
 *              Returns false if an exact match was not found. If false is returned, 
 *              position points to the element number where the data should be inserted if it was to be added to the array in sorted order.
 *
 *	时间:		2007.04.02
 *	作者:		lzl
 *	版本:		初始版本
 *	修改记录:	无
 *
 *********************************************************************************/
MYBOOL BinarySearch(void const * baseP, const signed long numOfElements, const signed long width, SearchFuncPtr searchF,
                         void const * searchData, const signed long other, signed long * position)
{
	signed long lPos = 0;
	signed long rPos = numOfElements - 1;
	signed long mPos;

	// 不可以小于 0
	//ErrNonFatalDisplayIf(numOfElements < 0, "SysBinarySearch argument error");

	// 
	// 二分查找
	// 
	while (lPos <= rPos)
	{
		mPos = (lPos + rPos) / 2;
		
		if (searchF(searchData, (unsigned char *)baseP+mPos*width, other) > 0) // mid value < search value
			lPos = mPos + 1;
		else
			rPos = mPos - 1;
	}
	*position = lPos;
	
	// if we've gone off the right end, don't do the final compare
	if (lPos >= numOfElements)
		return my_false;
	
	// otherwise, may not have checked current element for equality, do it now
	return (searchF(searchData, (unsigned char*)baseP + lPos * width, other) == 0);
}


signed short CmpFunc(const void * p1, const void * p2, unsigned long other)
{
    return memcmp(&((TableEntry*)p1)->py, &((TableEntry*)p2)->py, sizeof(PyType));
}

unsigned int FindVoiceOffset(const TableEntry * tableP, unsigned int tableLength, const PyType *py)
{
    signed long pos = 0;

    if (BinarySearch(tableP, tableLength, sizeof(TableEntry), CmpFunc,  py, 0, &pos))
    {
        return tableP[pos].offset;
    }

    return -1;
}


unsigned int VoiceToFile(void * outData, const TableEntry * tableP, unsigned int tableLength, const char * py)
{
    unsigned char * data;
    unsigned short  dataSize;
    unsigned int  offset;
    PyType  pyData;
    
    StrToPyType(py, &pyData);
    offset = FindVoiceOffset(tableP, tableLength, &pyData);
    if (offset == -1)
        return 0;
    //fseek(libFP, offset, SEEK_SET);
    //fread(&dataSize, 1, sizeof(unsigned short), libFP);
	dataSize = *((unsigned short*)(arrayWavDataR + offset));
	
    //data = (unsigned char*)malloc(dataSize);
    //fread(data, 1, dataSize, libFP);
    data = (unsigned char *)(arrayWavDataR + offset + sizeof(unsigned short));

	// 写到目标文件
    //dataSize = fwrite(data, 1, dataSize, dstFP);
    //free(data);
    if (outData)
	{
		memmove(outData, data, dataSize);
	}
    
    return dataSize;
}






//---------------------------------------------------------

static TableEntry * g_tableP = 0;
static unsigned int  g_tableSize = 0;
///////////////////////////////////////////////////////////////////////////////////////////
//  main
///////////////////////////////////////////////////////////////////////////////////////////
int OpenVoiceEngine()
{
	g_head = (HeadInfoRecordType *)arrayWavDataR;

	// ReadHead(g_vfp, g_head);
	
	g_tableSize = *((unsigned int*)(arrayWavDataR + sizeof(HeadInfoRecordType)));

	g_tableP = (TableEntry*)(arrayWavDataR + sizeof(HeadInfoRecordType) + sizeof(unsigned int));	// ReadTable(g_vfp, &g_tableSize);

	return 0;
}


void CloseVoiceEngine()
{
	g_tableSize = 0;
	g_tableP= 0;
}

static void StrReplace(char * src, const char *f, const char *n)
{
    char * p = src;
    int oldLen = (int)strlen(f);
    int newLen = (int)strlen(n);
    while(1)
    {
        p = strstr(p,f);
        if (p == 0)
            break;
        char * end = src + strlen(src);
        memmove(p+newLen, p+oldLen, (end-(p+oldLen)+1)*sizeof(char));
        memmove(p, n, newLen*sizeof(char));
        //p += max(newLen,oldLen);
        p += newLen;
    }
}

// ds pinyin conv to pinyin
static void dsPinyinConv(char * dspy)
{
    int len  = (int)strlen(dspy);
    if (dspy[len-1] == 'x')
    {
        dspy[len-1] = '2';
    }
    else if (dspy[len-1] == 'v')
    {
        dspy[len-1] = '3';
    }
    else if (dspy[len-1] == 'q')
    {
        dspy[len-1] = '4';
    }
    else if (strstr(dspy, "aa")  || strstr(dspy, "ee") || strstr(dspy, "ii") || strstr(dspy, "oo") || strstr(dspy, "uu") || strstr(dspy, "vv"))
    {
        StrReplace(dspy, "aa", "a");
        StrReplace(dspy, "ee", "e");
        StrReplace(dspy, "ii", "i");
        StrReplace(dspy, "oo", "o");
        StrReplace(dspy, "uu", "u");
        StrReplace(dspy, "vv", "v");
        strcat(dspy, "0");
    }
    else
    {
        strcat(dspy, "1");
    }
}

void * CreateVoiceFile(const char * pys, int * sizeOut)
{
	void * retBuf = 0;
    char pyList[64][12];
	int pyNum = 1;
    int i;

	{
		const char * p = pys;
	    char * o = pyList[0]; 
	    
	    while(*p)
	    {
	        if (*p == ',')
	        {
	            (*o) = 0;
	            o = pyList[pyNum++];
	        }
	        else
	        {
	            (*o) = (char)(*p);
	            o++;
	        }
	        p++;
	    }
	    (*o) = 0;	    
	}
    
    for(i = 0; i < pyNum; i++)
    {
        dsPinyinConv(pyList[i]);
    }
    

	if (g_tableP)
	{
		unsigned int  fileSize = 0;
		
		// 计算需要内存大小
		{
			if (g_head->format == 1)
			{
				WriteADPCMHead(NULL, 0);
				fileSize += sizeof(WaveIMAADPCM);
			}
			else
			{
				WritePCMHead(NULL, 0);
				fileSize += sizeof(WavePCM);
			}
	
			for(i = 0; i < pyNum; i++)
			{
				// 拼音转语音
                int temp = VoiceToFile(NULL, g_tableP, g_tableSize/sizeof(TableEntry), pyList[i]);
                if (temp == 0)
                    return NULL;
				fileSize += temp;
			}
		}
        *sizeOut = fileSize;
		// 生成数据
		retBuf = malloc(fileSize);		
		if (retBuf)
		{
			unsigned char * p = (unsigned char *)retBuf;
            unsigned int  wavDataSize = 0;
			
			if (g_head->format == 1)
				p += sizeof(WaveIMAADPCM);
			else
				p += sizeof(WavePCM);

			for(i = 0; i < pyNum; i++)
			{
				// 拼音转语音
				int temp = VoiceToFile(p, g_tableP, g_tableSize/sizeof(TableEntry), pyList[i]);
				p += temp;
                wavDataSize += temp;
			}

			if (g_head->format == 1)
				WriteADPCMHead(retBuf, wavDataSize);
			else
				WritePCMHead(retBuf, wavDataSize);
		}
	}
	
	return retBuf;
}
