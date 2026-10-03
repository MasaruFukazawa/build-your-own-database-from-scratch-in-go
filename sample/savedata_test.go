package sample

import (
	"os"
	"path/filepath"
	"testing"
)

func TestSaveData1(t *testing.T) {
	path := filepath.Join(t.TempDir(), "data.db")

	if err := SaveData1(path, []byte("hello")); err != nil {
		t.Fatal(err)
	}

	// 上書き(O_TRUNC)されることも確認
	if err := SaveData1(path, []byte("hi")); err != nil {
		t.Fatal(err)
	}

	got, err := os.ReadFile(path)

	if err != nil {
		t.Fatal(err)
	}

	if string(got) != "hi" {
		t.Fatalf("got %q, want %q", got, "hi")
	}
}
