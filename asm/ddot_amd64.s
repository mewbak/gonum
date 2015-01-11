// Copyright ©2015 The gonum Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// Some of the loop unrolling code is copied from:
// http://golang.org/src/math/big/arith_amd64.s
// which is distributed under these terms:
//
// Copyright (c) 2012 The Go Authors. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// 
//    * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//    * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


// TODO(fhs): use textflag.h after we drop Go 1.3 support
//#include "textflag.h"
// Don't insert stack check preamble.
#define NOSPLIT	4


// func DdotUnitary(x, y []float64) (sum float64)
// This function assumes len(y) >= len(x).
TEXT ·DdotUnitary(SB),NOSPLIT,$0
	MOVQ x_len+8(FP), DI	// n = len(x)
	MOVQ x+0(FP), R8
	MOVQ y+24(FP), R9
	
	MOVQ $0, SI				// i = 0
	MOVSD $(0.0), X7		// sum = 0
	
	SUBQ $2, DI				// n -= 2
	JL V1					// if n < 0 goto V1

U1:	// n >= 0
	// sum += x[i] * y[i] unrolled 2x.
	MOVUPD 0(R8)(SI*8), X0
	MOVUPD 0(R9)(SI*8), X1
	MULPD X1, X0
	ADDPD X0, X7
	
	ADDQ $2, SI				// i += 2
	SUBQ $2, DI				// n -= 2
	JGE U1					// if n >= 0 goto U1

V1:	// n > 0
	ADDQ $2, DI				// n += 2
	JLE E1					// if n <= 0 goto E1
	
	// sum += x[i] * y[i] for last iteration if n is odd.
	MOVSD 0(R8)(SI*8), X0
	MOVSD 0(R9)(SI*8), X1
	MULSD X1, X0
	ADDSD X0, X7

E1:
	// Add the two sums together.
	MOVSD X7, X0
	UNPCKHPD X7, X7
	ADDSD X0, X7
	MOVSD X7, sum+48(FP)	// return final sum
	RET
  