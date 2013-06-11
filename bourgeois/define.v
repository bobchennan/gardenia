`timescale 1ns/10ps

`define BYTE_SIZE 8 // in bit
`define WORD_SIZE 32 // in bit
`define INST_MEM_SIZE 1024 // in Byte
`define DATA_MEM_SIZE 1024 // in Byte
`define BLOCK_SIZE 1024 // in bit
`define CACHE_GROUP 4
`define CACHE_OFFSET_LEN 5
`define CACHE_INDEX_LEN 2
`define CACHE_TAG_LEN 25
`define MULTIPLE_ISSUE 26
`define UNIT_SIZE 8
`define REG_SIZE 6
`define GENERAL_RS_SIZE (1+1+32+32+8+8+1+1)
`define SW_RS_SIZE (1+1+32+32+32+8+8+8+1+1+1)
`define MAX_UNSIGN_INT ((1 << 32) -1)
`define CACHE_MISS_TIME 100