// Package sample はテストの書き方を示すためのサンプルパッケージ。
package sample

import "encoding/binary"

// EncodeUint32 は v をリトルエンディアンの 4 バイトに変換する。
func EncodeUint32(v uint32) []byte {
	buf := make([]byte, 4)
	binary.LittleEndian.PutUint32(buf, v)
	return buf
}

// DecodeUint32 はリトルエンディアンの 4 バイトを uint32 に変換する。
func DecodeUint32(buf []byte) uint32 {
	return binary.LittleEndian.Uint32(buf)
}
