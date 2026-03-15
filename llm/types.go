package llm

// gglaModel is implemented by GGLA and other model file types
type gglaModel interface {
	KV() KV
	Tensors() Tensors
}

// KV is a map of key-value pairs from a model file header
type KV map[string]any

// Tensors holds a list of tensors and the offset to the first tensor data
type Tensors struct {
	Items  []*Tensor
	Offset uint64
}

// Tensor represents a single tensor in a model file
type Tensor struct {
	Name   string
	Kind   uint32
	Offset uint64

	// Shape is the number of elements in each dimension
	Shape []uint64
}

// elements returns the total number of elements in the tensor
func (t Tensor) elements() uint64 {
	if len(t.Shape) == 0 {
		return 0
	}
	n := uint64(1)
	for _, s := range t.Shape {
		n *= s
	}
	return n
}

// blockSize returns the number of elements per quantization block for the tensor type
func (t Tensor) blockSize() uint64 {
	switch t.Kind {
	case 0, // F32
		1,  // F16
		24, // I8
		25, // I16
		26, // I32
		27, // I64
		28, // F64
		30: // BF16
		return 1
	case 2,  // Q4_0
		3,   // Q4_1
		6,   // Q5_0
		7,   // Q5_1
		8,   // Q8_0
		9,   // Q8_1
		20:  // IQ4_NL
		return 32
	default:
		return 256
	}
}

// typeSize returns the number of bytes per quantization block for the tensor type
func (t Tensor) typeSize() uint64 {
	blockSize := t.blockSize()
	switch t.Kind {
	case 0: // F32
		return 4
	case 1: // F16
		return 2
	case 2: // Q4_0
		return 2 + blockSize/2
	case 3: // Q4_1
		return 2 + 2 + blockSize/2
	case 6: // Q5_0
		return 2 + 4 + blockSize/2
	case 7: // Q5_1
		return 2 + 2 + 4 + blockSize/2
	case 8: // Q8_0
		return 2 + blockSize
	case 9: // Q8_1
		return 2 + 2 + blockSize
	case 10: // Q2_K
		return blockSize/16 + blockSize/4 + 2 + 2
	case 11: // Q3_K
		return blockSize/8 + blockSize/4 + 12 + 2
	case 12: // Q4_K
		return 2 + 2 + 12 + blockSize/2
	case 13: // Q5_K
		return 2 + 2 + 12 + blockSize/8 + blockSize/2
	case 14: // Q6_K
		return blockSize/2 + blockSize/4 + blockSize/16 + 2
	case 15: // Q8_K
		return 4 + blockSize + 2*blockSize/16
	case 24: // I8
		return 1
	case 25: // I16
		return 2
	case 26: // I32
		return 4
	case 27: // I64
		return 8
	case 28: // F64
		return 8
	case 30: // BF16
		return 2
	default:
		return 0
	}
}

// Size returns the number of bytes required to store the tensor data
func (t Tensor) Size() uint64 {
	return t.elements() * t.typeSize() / t.blockSize()
}
