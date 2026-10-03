package sample

import (
	"bytes"
	"testing"
)

// TestUint32RoundTrip は EncodeUint32 / DecodeUint32 で
// 値を往復変換できることを確認するテーブル駆動テストのサンプル。
func TestUint32RoundTrip(t *testing.T) {
	tests := []struct {
		name string
		in   uint32
		want []byte
	}{
		{name: "zero", in: 0, want: []byte{0x00, 0x00, 0x00, 0x00}},
		{name: "one", in: 1, want: []byte{0x01, 0x00, 0x00, 0x00}},
		{name: "mixed", in: 0x12345678, want: []byte{0x78, 0x56, 0x34, 0x12}},
		{name: "max", in: 0xFFFFFFFF, want: []byte{0xFF, 0xFF, 0xFF, 0xFF}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			buf := EncodeUint32(tt.in)
			if !bytes.Equal(buf, tt.want) {
				t.Fatalf("EncodeUint32(%#x) = %x, want %x", tt.in, buf, tt.want)
			}
			if got := DecodeUint32(buf); got != tt.in {
				t.Fatalf("DecodeUint32(%x) = %#x, want %#x", buf, got, tt.in)
			}
		})
	}
}
