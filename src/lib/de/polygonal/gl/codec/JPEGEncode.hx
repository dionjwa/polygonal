/*
 *                            _/                                                    _/   
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/    
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/     
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/      
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/       
 *   _/                            _/        _/                                          
 *  _/                        _/_/      _/_/                                             
 *                                                                                       
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009-2010 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
#if (!flash && !cpp)
"The JPEGEncode class is only available for flash/cpp"
#end

package de.polygonal.gl.codec;


#if flash10
import de.polygonal.ds.mem.ByteMemory;
import de.polygonal.ds.mem.DoubleMemory;
import de.polygonal.ds.mem.IntMemory;
import de.polygonal.ds.mem.MemoryManager;
#end

import flash.display.BitmapData;
import flash.utils.ByteArray;

using Std;
using de.polygonal.core.math.Mathematics;

private typedef ByteAccess =
#if flash10
ByteMemory
#elseif neko
ArrAccess<Int>
#else
ArrAccess<Int>
#end

private typedef IntAccess =
#if flash10
IntMemory
#elseif neko
ArrAccess<Int>
#else
ArrAccess<Int>
#end

private typedef FloatAccess =
#if flash10
DoubleMemory
#elseif neko
ArrAccess<Float>
#else
ArrAccess<Float>
#end

private class ArrAccess<T>
{
	var _a:Array<T>;
	
	public function new()
	{
		_a = new Array<T>();
	}
	
	public function fromArray(a:Array<T>):Void
	{
		for (i in 0...a.length) _a[i] = a[i];
	}
	
	inline public function get(i:Int):T { return _a[i]; }
	inline public function set(i:Int, x:T):Void { _a[i] = x; }
}

/**
 * This is a highly optimized version of the JPEG encoder from the flex framework (mx.graphics.codec).<br/>
 * The JPEGEncoder class converts raw bitmap images into encoded images using Joint Photographic Experts Group (JPEG) compression.
 * For information about the JPEG algorithm, see the document http://www.opennet.ru/docs/formats/jpeg.txt by Cristi Cuturicu.
 */
class JPEGEncode
{
	static var STD_DC_LUMINANCE_NRCODES   = [0, 0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0];
	static var STD_DC_LUMINANCE_VALUES    = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	static var STD_DC_CHROMINANCE_NRCODES = [0, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0];
	static var STD_DC_CHROMINANCE_VALUES  = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	static var STD_AC_LUMINANCE_NRCODES   = [0, 0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 0x7D];
	static var STD_AC_LUMINANCE_VALUES = 
	[
		0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12,
		0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07,
		0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08,
		0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0,
		0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0A, 0x16,
		0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28,
		0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
		0x3A, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49,
		0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
		0x5A, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,
		0x6A, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
		0x7A, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
		0x8A, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98,
		0x99, 0x9A, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7,
		0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6,
		0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5,
		0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xD2, 0xD3, 0xD4,
		0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2,
		0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA,
		0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8,
		0xF9, 0xFA
	];
	static var STD_AC_CHROMINANCE_NRCODES = [0, 0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 0x77];
	static var STD_AC_CHROMINANCE_VALUES =
	[
		0x00, 0x01, 0x02, 0x03, 0x11, 0x04, 0x05, 0x21,
		0x31, 0x06, 0x12, 0x41, 0x51, 0x07, 0x61, 0x71,
		0x13, 0x22, 0x32, 0x81, 0x08, 0x14, 0x42, 0x91,
		0xA1, 0xB1, 0xC1, 0x09, 0x23, 0x33, 0x52, 0xF0,
		0x15, 0x62, 0x72, 0xD1, 0x0A, 0x16, 0x24, 0x34,
		0xE1, 0x25, 0xF1, 0x17, 0x18, 0x19, 0x1A, 0x26,
		0x27, 0x28, 0x29, 0x2A, 0x35, 0x36, 0x37, 0x38,
		0x39, 0x3A, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
		0x49, 0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
		0x59, 0x5A, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68,
		0x69, 0x6A, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
		0x79, 0x7A, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
		0x88, 0x89, 0x8A, 0x92, 0x93, 0x94, 0x95, 0x96,
		0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3, 0xA4, 0xA5,
		0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4,
		0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3,
		0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xD2,
		0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA,
		0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9,
		0xEA, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8,
		0xF9, 0xFA
	];
	static var ZIGZAG = 
	[
		 0,  1,  5,  6, 14, 15, 27, 28,
		 2,  4,  7, 13, 16, 26, 29, 42,
		 3,  8, 12, 17, 25, 30, 41, 43,
		 9, 11, 18, 24, 31, 40, 44, 53,
		10, 19, 23, 32, 39, 45, 52, 54,
		20, 22, 33, 38, 46, 51, 55, 60,
		21, 34, 37, 47, 50, 56, 59, 61,
		35, 36, 48, 49, 57, 58, 62, 63
	];
	
	var _std_dc_luminance_nrcodes:ByteAccess;
	var _std_dc_luminance_values:ByteAccess;
	var _std_dc_chrominance_nrcodes:ByteAccess;
	var _std_dc_chrominance_values:ByteAccess;
	var _std_ac_luminance_nrcodes:ByteAccess;
	var _std_ac_luminance_values:ByteAccess;
	var _std_ac_chrominance_nrcodes:ByteAccess;
	var _std_ac_chrominance_values:ByteAccess;
	var _ZigZag:ByteAccess;
	
	var _category:ByteAccess;
	var _YTable:ByteAccess;
	var _UVTable:ByteAccess;
	var _fdtbl_Y:FloatAccess;
	var _fdtbl_UV:FloatAccess;
	
	var _DU:IntAccess;
	var _YDU:FloatAccess;
	var _UDU:FloatAccess;
	var _VDU:FloatAccess;
	
	var _byteout:ByteArray;
	var _bytenew:Int;
	var _bytepos:Int;
	
	var _YDC_HT_L:IntAccess;
	var _YDC_HT_V:IntAccess;
	
	var _UVDC_HT_L:IntAccess;
	var _UVDC_HT_V:IntAccess;
	
	var _YAC_HT_L:IntAccess;
	var _YAC_HT_V:IntAccess;
	
	var _UVAC_HT_L:IntAccess;
	var _UVAC_HT_V:IntAccess;
	
	var _bitcode_l:IntAccess;
	var _bitcode_v:IntAccess;
	
	var _sourceByteArray:ByteArray;
	var _sourceBitmapData:BitmapData;
	
	function _initTables():Void
	{
		#if flash10
		_std_dc_luminance_nrcodes = ByteMemory.ofArray(STD_DC_LUMINANCE_NRCODES);
		_std_dc_luminance_values = ByteMemory.ofArray(STD_DC_LUMINANCE_VALUES);
		_std_dc_chrominance_nrcodes = ByteMemory.ofArray(STD_DC_CHROMINANCE_NRCODES);
		_std_dc_chrominance_values = ByteMemory.ofArray(STD_DC_CHROMINANCE_VALUES);
		_std_ac_luminance_nrcodes = ByteMemory.ofArray(STD_AC_LUMINANCE_NRCODES);
		_std_ac_luminance_values = ByteMemory.ofArray(STD_AC_LUMINANCE_VALUES);
		_std_ac_chrominance_nrcodes = ByteMemory.ofArray(STD_AC_CHROMINANCE_NRCODES);
		_std_ac_chrominance_values = ByteMemory.ofArray(STD_AC_CHROMINANCE_VALUES);
		
		_ZigZag = ByteMemory.ofArray(ZIGZAG);
		
		_bitcode_l = new IntMemory(65535, "JPEGEncode.bitcode_l");
		_bitcode_v = new IntMemory(65535, "JPEGEncode.bitcode_v");
		_category  = new ByteMemory(65535, "JPEGEncode.category");
		_YTable    = new ByteMemory(64, "JPEGEncode.YTable");
		_UVTable   = new ByteMemory(64, "JPEGEncode.UVTable");
		_DU        = new IntMemory(64, "JPEGEncode.DU");
		_YDU       = new DoubleMemory(64, "JPEGEncode.YDU");
		_UDU       = new DoubleMemory(64, "JPEGEncode.UDU");
		_VDU       = new DoubleMemory(64, "JPEGEncode.VDU");
		_fdtbl_Y   = new DoubleMemory(64, "JPEGEncode.fdtbl_Y");
		_fdtbl_UV  = new DoubleMemory(64, "JPEGEncode.fdtbl_UV");
		
		//huffman tables
		_YDC_HT_L = new IntMemory(12, "JPEGEncode.YDC_HT_L");
		_YDC_HT_V = new IntMemory(12, "JPEGEncode.YDC_HT_V");
		
		_computeHuffmanTbl(_std_dc_luminance_nrcodes  , _std_dc_luminance_values, _YDC_HT_L, _YDC_HT_V);
		
		_UVDC_HT_L = new IntMemory(12, "JPEGEncode.UVDC_HT_L");
		_UVDC_HT_V = new IntMemory(12, "JPEGEncode.UVDC_HT_V");
		_computeHuffmanTbl(_std_dc_chrominance_nrcodes, _std_dc_chrominance_values, _UVDC_HT_L, _UVDC_HT_V);
		
		_YAC_HT_L = new IntMemory(251, "JPEGEncode.YAC_HT_L");
		_YAC_HT_V = new IntMemory(251, "JPEGEncode.YAC_HT_V");
		_computeHuffmanTbl(_std_ac_luminance_nrcodes  , _std_ac_luminance_values, _YAC_HT_L, _YAC_HT_V);
		
		_UVAC_HT_L = new IntMemory(251, "JPEGEncode.UVAC_HT_L");
		_UVAC_HT_V = new IntMemory(251, "JPEGEncode.UVAC_HT_V");
		_computeHuffmanTbl(_std_ac_chrominance_nrcodes, _std_ac_chrominance_values, _UVAC_HT_L, _UVAC_HT_V);
		#else
		_std_dc_luminance_nrcodes = new ArrAccess<Int>();
		_std_dc_luminance_nrcodes.fromArray(STD_DC_LUMINANCE_NRCODES);
		
		_std_dc_luminance_values = new ArrAccess<Int>();
		_std_dc_luminance_values.fromArray(STD_DC_LUMINANCE_VALUES);
		
		_std_dc_chrominance_nrcodes = new ArrAccess<Int>();
		_std_dc_chrominance_nrcodes.fromArray(STD_DC_CHROMINANCE_NRCODES);
		
		_std_dc_chrominance_values = new ArrAccess<Int>();
		_std_dc_chrominance_values.fromArray(STD_DC_CHROMINANCE_VALUES);
		
		_std_ac_luminance_nrcodes = new ArrAccess<Int>();
		_std_ac_luminance_nrcodes.fromArray(STD_AC_LUMINANCE_NRCODES);
		
		_std_ac_luminance_values = new ArrAccess<Int>();
		_std_ac_luminance_values.fromArray(STD_AC_LUMINANCE_VALUES);
		
		_std_ac_chrominance_nrcodes = new ArrAccess<Int>();
		_std_ac_chrominance_nrcodes.fromArray(STD_AC_CHROMINANCE_NRCODES);
		
		_std_ac_chrominance_values = new ArrAccess<Int>();
		_std_ac_chrominance_values.fromArray(STD_AC_CHROMINANCE_VALUES);
		
		_ZigZag = new ArrAccess<Int>();
		_ZigZag.fromArray(ZIGZAG);
		
		_bitcode_l = new ArrAccess<Int>();
		_bitcode_v = new ArrAccess<Int>();
		_category  = new ArrAccess<Int>();
		_YTable    = new ArrAccess<Int>();
		_UVTable   = new ArrAccess<Int>();
		_DU        = new ArrAccess<Int>();
		_YDU       = new ArrAccess<Float>();
		_UDU       = new ArrAccess<Float>();
		_VDU       = new ArrAccess<Float>();
		_fdtbl_Y   = new ArrAccess<Float>();
		_fdtbl_UV  = new ArrAccess<Float>();
		
		//huffman tables
		_YDC_HT_L = new ArrAccess<Int>();
		_YDC_HT_V = new ArrAccess<Int>();
		
		_computeHuffmanTbl(_std_dc_luminance_nrcodes  , _std_dc_luminance_values, _YDC_HT_L, _YDC_HT_V);
		
		_UVDC_HT_L = new ArrAccess<Int>();
		_UVDC_HT_V = new ArrAccess<Int>();
		_computeHuffmanTbl(_std_dc_chrominance_nrcodes, _std_dc_chrominance_values, _UVDC_HT_L, _UVDC_HT_V);
		
		_YAC_HT_L = new ArrAccess<Int>();
		_YAC_HT_V = new ArrAccess<Int>();
		_computeHuffmanTbl(_std_ac_luminance_nrcodes  , _std_ac_luminance_values, _YAC_HT_L, _YAC_HT_V);
		
		_UVAC_HT_L = new ArrAccess<Int>();
		_UVAC_HT_V = new ArrAccess<Int>();
		_computeHuffmanTbl(_std_ac_chrominance_nrcodes, _std_ac_chrominance_values, _UVAC_HT_L, _UVAC_HT_V);
		#end
	}
	
	/**
	 * @param quality A value between 0.0 and 100.0. The smaller the <i>quality</i> value, the smaller the file size of the resultant image. 
	 * The value does not affect the encoding speed. Note that even though this value is a number between 0.0 and 100.0, 
	 * it does not represent a percentage. The default value is 50.0.
	 */
	public function new(?quality = 50)
	{
		_bytenew = 0;
		_bytepos = 7;
		
		if (quality <= 0) quality = 1;
		if (quality > 100) quality = 100;
		
		var sf = 0;
		if (quality < 50)
			sf = (5000 / quality).int();
		else
			sf = (200 - quality * 2).int();
		
		_initTables();
		_initCategoryNumber();
		_initQuantTables(sf);
	}

	public function free():Void
	{
		#if flash10
		_std_dc_luminance_nrcodes.free();
		_std_dc_luminance_values.free();
		_std_dc_chrominance_nrcodes.free();
		_std_dc_chrominance_values.free();
		_std_ac_luminance_nrcodes.free();
		_std_ac_luminance_values.free();
		_std_ac_chrominance_nrcodes.free();
		_std_ac_chrominance_values.free();
		_ZigZag.free();
		
		_category.free();
		_YTable.free();
		_UVTable.free();
		_fdtbl_Y.free();
		_fdtbl_UV.free();
		
		_DU.free();
		_YDU.free();
		_UDU.free();
		_VDU.free();
		
		_byteout = null;
		
		_YDC_HT_L.free();
		_YDC_HT_V.free();
		
		_UVDC_HT_L.free();
		_UVDC_HT_V.free();
		
		_YAC_HT_L.free();
		_YAC_HT_V.free();
		
		_UVAC_HT_L.free();
		_UVAC_HT_V.free();
		
		_bitcode_l.free();
		_bitcode_v.free();
		#end
	}
	
	public function getContentType():String
	{
		return "image/jpeg";
	}

	/**
	 * Converts a ByteArray object containing raw pixels in 32-bit ARGB (Alpha, Red, Green, Blue) format
	 * to a new JPEG-encoded ByteArray object.<br/>
	 * The original ByteArray is left unchanged.
	 * Transparency is not supported; however you still must represent each pixel as four bytes in ARGB format.
	 * @param byteArray The input ByteArray object containing raw pixels.
	 * This ByteArray should contain <i>4 * width * height</i> bytes. Each pixel is represented by 4 bytes, in the order ARGB.
	 * The first four bytes represent the top-left pixel of the image.
	 * The next four bytes represent the pixel to its right, etc.
	 * Each row follows the previous one without any padding.
	 * @param width The width of the input image, in pixels.
	 * @param height The height of the input image, in pixels.
	 * @return Returns a ByteArray object containing JPEG-encoded image data. 
	 */
	public function encodeByteArray(byteArray:ByteArray, width:Int, height:Int):ByteArray
	{
		_sourceByteArray = byteArray;
		_sourceBitmapData = null;
		return _internalEncode(width, height);
	}

	/**
	 * Converts a BitmapData object to a new JPEG-encoded ByteArray object.<br/>
	 * The original ByteArray is left unchanged.
	 */
	public function encode(bitmapData:BitmapData):ByteArray
	{
		_sourceByteArray = null;
		_sourceBitmapData = bitmapData;
		return _internalEncode(bitmapData.width, bitmapData.height);
	}
	
	function _computeHuffmanTbl(nrcodes:ByteAccess, std_table:ByteAccess, out_len:IntAccess, out_val:IntAccess):Void
	{
		var codevalue = 0;
		var pos_in_table = 0;
		
		for (k in 1...16 + 1)
		{
			var j = 1;
			while (j <= nrcodes.get(k))
			{
				var i = std_table.get(pos_in_table);
				out_val.set(i, codevalue);
				out_len.set(i, k);
				
				pos_in_table++;
				codevalue++;
				j++;
			}
			codevalue <<= 1;
		}
	}

	function _initCategoryNumber():Void
	{
		var nrlower = 1;
		var nrupper = 2;
		
		for (cat in 1...15 + 1)
		{
			for (nr in nrlower...nrupper)
			{
				var i = (32767 + nr);
				_category.set(i, cat);
				_bitcode_l.set(i, cat);
				_bitcode_v.set(i, nr);
			}
			var nr = -(nrupper - 1);
			while (nr <= -nrlower)
			{
				var i = 32767 + nr;
				_category.set(i, cat);
				_bitcode_l.set(i, cat);
				_bitcode_v.set(i, nrupper - 1 + nr);
				nr++;
			}
			
			nrlower <<= 1;
			nrupper <<= 1;
		}
	}

	function _initQuantTables(sf:Int):Void
	{
		var YQT =
		[
			16, 11, 10, 16,  24,  40,  51,  61,
			12, 12, 14, 19,  26,  58,  60,  55,
			14, 13, 16, 24,  40,  57,  69,  56,
			14, 17, 22, 29,  51,  87,  80,  62,
			18, 22, 37, 56,  68, 109, 103,  77,
			24, 35, 55, 64,  81, 104, 113,  92,
			49, 64, 78, 87, 103, 121, 120, 101,
			72, 92, 95, 98, 112, 100, 103,  99
		];
		
		for (i in 0...64)
		{
			var t = ((YQT[i] * sf + 50) / 100).int();
			if (t < 1) t = 1;
			else if (t > 255) t = 255;
			_YTable.set(_ZigZag.get(i), t);
		}
		
		var UVQT =
		[
			17, 18, 24, 47, 99, 99, 99, 99,
			18, 21, 26, 66, 99, 99, 99, 99,
			24, 26, 56, 99, 99, 99, 99, 99,
			47, 66, 99, 99, 99, 99, 99, 99,
			99, 99, 99, 99, 99, 99, 99, 99,
			99, 99, 99, 99, 99, 99, 99, 99,
			99, 99, 99, 99, 99, 99, 99, 99,
			99, 99, 99, 99, 99, 99, 99, 99
		];
		
		for (i in 0...64)
		{
			var t = ((UVQT[i] * sf + 50) / 100).int();
			if (t < 1) t = 1;
			else if (t > 255) t = 255;
			_UVTable.set(_ZigZag.get(i), t);
		}
		
		var aasf =
		[
			1.0, 1.387039845, 1.306562965, 1.175875602,
			1.0, 0.785694958, 0.541196100, 0.275899379
		];
		
		var i = 0;
		for (row in 0...8)
		{
			for (col in 0...8)
			{
				var t = aasf[row] * aasf[col] * 8;
				_fdtbl_Y.set(i, (1 / (_YTable.get(_ZigZag.get(i)) * t)));
				_fdtbl_UV.set(i, (1 / (_UVTable.get(_ZigZag.get(i)) * t)));
				i++;
			}
		}
	}

	function _internalEncode(width:Int, height:Int):ByteArray
	{
		_byteout = new ByteArray();
		_bytenew = 0;
		_bytepos = 7;
		
		_writeWord(0xFFD8);
		_writeAPP0();
		_writeDQT();
		_writeSOF0(width, height);
		_writeDHT();
		_writeSOS();
		
		var DCY = .0;
		var DCU = .0;
		var DCV = .0;
		_bytenew = 0;
		_bytepos = 7;
		
		var ypos = 0;
		var xpos = 0;
		while (ypos < height)
		{
			xpos = 0;
			while (xpos < width)
			{
				RGB2YUV(xpos, ypos, width, height);
				DCY = _processDU(_YDU, _fdtbl_Y , DCY, _YDC_HT_L, _YDC_HT_V, _YAC_HT_L, _YAC_HT_V);
				DCU = _processDU(_UDU, _fdtbl_UV, DCU, _UVDC_HT_L, _UVDC_HT_V, _UVAC_HT_L, _UVAC_HT_V);
				DCV = _processDU(_VDU, _fdtbl_UV, DCV, _UVDC_HT_L, _UVDC_HT_V, _UVAC_HT_L, _UVAC_HT_V);
				xpos += 8;
			}
			ypos += 8;
		}
		
		if (_bytepos >= 0)
			_writeBits(_bytepos + 1, (1 << (_bytepos + 1)) - 1);
		
		_writeWord(0xFFD9);
		return _byteout;
	}
	
	function RGB2YUV(xpos:Int, ypos:Int, width:Int, height:Int):Void
	{
		if (_sourceBitmapData != null)
		{
			var k = 0;
			for (j in 0...8)
			{
				var y = ypos + j;
				if (y >= height) y = height - 1;
				
				for (i in 0...8)
				{
					var x = xpos + i;
					if (x >= width) x = width - 1;
					
					var pixel = _sourceBitmapData.getPixel32(x, y);
					
					var r = (pixel >> 16) & 0xFF;
					var g = (pixel >> 8) & 0xFF;
					var b = pixel & 0xFF;
					
					_YDU.set(k, .29900 * r + .58700 * g + .11400 * b - 128);
					_UDU.set(k,-.16874 * r - .33126 * g + .50000 * b);
					_VDU.set(k, .50000 * r - .41869 * g - .08131 * b);
					
					k++;
				}
			}
		}
		else
		{
			var k = 0;
			for (j in 0...8)
			{
				var y = ypos + j;
				if (y >= height) y = height - 1;
				
				for (i in 0...8)
				{
					var x = xpos + i;
					if (x >= width) x = width - 1;
					
					_sourceByteArray.position = 4 * (y * width + x);
					var pixel = _sourceByteArray.readUnsignedInt();
					
					var r = (pixel >> 16) & 0xFF;
					var g = (pixel >> 8) & 0xFF;
					var b = pixel & 0xFF;
					
					_YDU.set(k, .29900 * r + .58700 * g + .11400 * b - 128);
					_UDU.set(k,-.16874 * r - .33126 * g + .50000 * b);
					_VDU.set(k, .50000 * r - .41869 * g - .08131 * b);
					
					k++;
				}
			}
		}
	}

	function _processDU(CDU:FloatAccess, fdtbl:FloatAccess, DC:Float, HTDC_L:IntAccess, HTDC_V:IntAccess, HTAC_L:IntAccess, HTAC_V:IntAccess):Float
	{
		var EOB_l = HTAC_L.get(0);
		var EOB_v = HTAC_V.get(0);
		var M16zeroes_l = HTAC_L.get(0xF0);
		var M16zeroes_v = HTAC_V.get(0xF0);
		
		var DU_DCT = _fDCTQuant(CDU, fdtbl);
		
		for (i in 0...64) _DU.set(_ZigZag.get(i), DU_DCT.get(i).int());
		
		var du0 = _DU.get(0);
		var Diff = (du0 - DC).int();
		DC = du0;
		
		if (Diff == 0)
			_writeBits(HTDC_L.get(0), HTDC_V.get(0));
		else
		{
			var pos = (32767 + Diff);
			var tmp = _category.get(pos);
			_writeBits(HTDC_L.get(tmp), HTDC_V.get(tmp));
			_writeBits(_bitcode_l.get(pos), _bitcode_v.get(pos));
		}
		
		var end0pos = 63;
		
		while (end0pos > 0 && (_DU.get(end0pos) == 0)) end0pos--;
		
		if (end0pos == 0)
		{
			_writeBits(EOB_l, EOB_v);
			return DC;
		}
		
		var i = 1;
		while (i <= end0pos)
		{
			var startpos = i;
			while ((_DU.get(i) == 0) && (i <= end0pos)) i++;
			var nrzeroes = i - startpos;
			if (nrzeroes >= 16)
			{
				var lng = nrzeroes >> 4;
				var nrmarker = 1;
				while (nrmarker <= lng)
				{
					_writeBits(M16zeroes_l, M16zeroes_v);
					nrmarker++;
				}
				nrzeroes = nrzeroes & 0xF;
			}
			
			var pos = 32767 + _DU.get(i);
			var tmp = ((nrzeroes << 4) + _category.get(pos));
			_writeBits(HTAC_L.get(tmp), HTAC_V.get(tmp));
			_writeBits(_bitcode_l.get(pos), _bitcode_v.get(pos));
			i++;
		}
		
		if (end0pos != 63) _writeBits(EOB_l, EOB_v);
		
		return DC;
	}
	
	function _fDCTQuant(data:FloatAccess, fdtbl:FloatAccess):FloatAccess
	{
		var dataOff = 0;
		
		var a:Float;
		var b:Float;
		
		var i0, i1, i2, i3, i4, i5, i6, i7, i8, i16, i24, i32, i40, i48, i56;
		var tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp10, tmp11, tmp12, tmp13;
		var z1, z2, z3, z4, z5, z11, z13;
		
		for (i in 0...8)
		{
			i1 = dataOff + 1;
			i2 = dataOff + 2;
			i3 = dataOff + 3;
			i4 = dataOff + 4;
			i6 = dataOff + 6;
			i5 = dataOff + 5;
			i7 = dataOff + 7;
			
			a = data.get(dataOff);
			b = data.get(i7);
			tmp0 = a + b;
			tmp7 = a - b;
			
			a = data.get(i1);
			b = data.get(i6);
			tmp1 = a + b;
			tmp6 = a - b;
			
			a = data.get(i2);
			b = data.get(i5);
			tmp2 = a + b;
			tmp5 = a - b;
			
			a = data.get(i3);
			b = data.get(i4);
			tmp3 = a + b;
			tmp4 = a - b;
			
			tmp10 = tmp0 + tmp3;
			tmp13 = tmp0 - tmp3;
			tmp11 = tmp1 + tmp2;
			tmp12 = tmp1 - tmp2;
			
			data.set(dataOff, tmp10 + tmp11);
			data.set(i4, tmp10 - tmp11);
			
			z1 = (tmp12 + tmp13) * 0.707106781;
			data.set(i2, tmp13 + z1);
			data.set(i6, tmp13 - z1);
			
			tmp10 = tmp4 + tmp5;
			tmp11 = tmp5 + tmp6;
			tmp12 = tmp6 + tmp7;
			
			z5 = (tmp10 - tmp12) * 0.382683433;
			z2 = 0.541196100 * tmp10 + z5;
			z4 = 1.306562965 * tmp12 + z5;
			z3 = tmp11 * 0.707106781;
			
			z11 = tmp7 + z3;
			z13 = tmp7 - z3;
			
			data.set(i5, z13 + z2);
			data.set(i3, z13 - z2);
			data.set(i1, z11 + z4);
			data.set(i7, z11 - z4);
			
			dataOff += 8;
		}
		
		dataOff = 0;
		for (i in 0...8)
		{
			i0  = dataOff + 0;
			i8  = dataOff + 8;
			i16 = dataOff + 16;
			i24 = dataOff + 24;
			i32 = dataOff + 32;
			i40 = dataOff + 40;
			i48 = dataOff + 48;
			i56 = dataOff + 56;
			
			tmp0 = data.get(dataOff) + data.get(i56);
			tmp7 = data.get(dataOff) - data.get(i56);
			tmp1 = data.get(i8)      + data.get(i48);
			tmp6 = data.get(i8)      - data.get(i48);
			tmp2 = data.get(i16)     + data.get(i40);
			tmp5 = data.get(i16)     - data.get(i40);
			tmp3 = data.get(i24)     + data.get(i32);
			tmp4 = data.get(i24)     - data.get(i32);
			
			tmp10 = tmp0 + tmp3;
			tmp13 = tmp0 - tmp3;
			tmp11 = tmp1 + tmp2;
			tmp12 = tmp1 - tmp2;
			
			data.set(dataOff, tmp10 + tmp11);
			data.set(i32, tmp10 - tmp11);
			
			z1 = (tmp12 + tmp13) * 0.707106781;
			data.set(i16, tmp13 + z1);
			data.set(i48, tmp13 - z1);
			
			tmp10 = tmp4 + tmp5;
			tmp11 = tmp5 + tmp6;
			tmp12 = tmp6 + tmp7;
			
			z5 = (tmp10 - tmp12) * 0.382683433;
			z2 = 0.541196100 * tmp10 + z5;
			z4 = 1.306562965 * tmp12 + z5;
			z3 = tmp11 * 0.707106781;
			
			z11 = tmp7 + z3;
			z13 = tmp7 - z3;
			
			data.set(i40, z13 + z2);
			data.set(i24, z13 - z2);
			data.set(i8 , z11 + z4);
			data.set(i56, z11 - z4);
			
			dataOff++;
		}
		
		for (i in 0...64) data.set(i, (data.get(i) * fdtbl.get(i)).round());
		
		return data;
	}

	inline function _writeBits(len:Int, value:Int):Void
	{
		var posval = len - 1;
		while (posval >= 0)
		{
			if (value & (1 << posval) != 0) _bytenew |= (1 << _bytepos);
			
			posval--;
			_bytepos--;
			
			if (_bytepos < 0)
			{
				if (_bytenew == 0xFF)
				{
					_writeByte(0xFF);
					_writeByte(0);
				}
				else
					_writeByte(_bytenew);
				
				_bytepos = 7;
				_bytenew = 0;
			}
		}
	}

	function _writeAPP0():Void
	{
		_writeWord(0xFFE0);
		_writeWord(16);
		_writeByte(0x4A);
		_writeByte(0x46);
		_writeByte(0x49);
		_writeByte(0x46);
		_writeByte(0);
		_writeByte(1);
		_writeByte(1);
		_writeByte(0);
		_writeWord(1);
		_writeWord(1);
		_writeByte(0);
		_writeByte(0);
	}

	function _writeDQT():Void
	{
		_writeWord(0xFFDB);
		_writeWord(132);
		_writeByte(0);
		
		for (i in 0...64) _writeByte(_YTable.get(i));
		
		_writeByte(1);
		
		for (i in 0...64) _writeByte(_UVTable.get(i));
	}

	function _writeSOF0(width:Int, height:Int):Void
	{
		_writeWord(0xFFC0);
		_writeWord(17);
		_writeByte(8);
		_writeWord(height);
		_writeWord(width);
		_writeByte(3);
		_writeByte(1);
		_writeByte(0x11);
		_writeByte(0);
		_writeByte(2);
		_writeByte(0x11);
		_writeByte(1);
		_writeByte(3);
		_writeByte(0x11);
		_writeByte(1);
	}
	
	function _writeDHT():Void
	{
		_writeWord(0xFFC4);
		_writeWord(0x01A2);
		
		_writeByte(0);
		
		for (i in 0...16) _writeByte(_std_dc_luminance_nrcodes.get(i + 1));
		for (i in 0...11 + 1) _writeByte(_std_dc_luminance_values.get(i));
		
		_writeByte(0x10);
		
		for (i in 0...16) _writeByte(_std_ac_luminance_nrcodes.get(i + 1));
		for (i in 0...161 + 1) _writeByte(_std_ac_luminance_values.get(i));
		
		_writeByte(1);
		
		for (i in 0...16) _writeByte(_std_dc_chrominance_nrcodes.get(i + 1));
		for (i in 0...11 + 1) _writeByte(_std_dc_chrominance_values.get(i));
		
		_writeByte(0x11);
		
		for (i in 0...16) _writeByte(_std_ac_chrominance_nrcodes.get(i + 1));
		for (i in 0...161 + 1) _writeByte(_std_ac_chrominance_values.get(i));
	}

	function _writeSOS():Void
	{
		_writeWord(0xFFDA);
		_writeWord(12);
		_writeByte(3);
		_writeByte(1);
		_writeByte(0);
		_writeByte(2);
		_writeByte(0x11);
		_writeByte(3);
		_writeByte(0x11);
		_writeByte(0);
		_writeByte(0x3f);
		_writeByte(0);
	}
	
	function _writeByte(value:Int):Void
	{
		_byteout.writeByte(value);
	}
	
	function _writeWord(value:Int):Void
	{
		_writeByte((value >> 8) & 0xFF);
		_writeByte(value & 0xFF);
	}
}