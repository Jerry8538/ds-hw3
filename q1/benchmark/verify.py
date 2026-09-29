import sys

def read_matrix(filename):
    matrix = {}
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if parts:
                # The first element is the row index, followed by the row values[cite: 2]
                matrix[int(parts[0])] = [int(x) for x in parts[1:]]
    return [matrix[i] for i in sorted(matrix.keys())]

def multiply(A, B):
    # Computes C = A x B[cite: 1]
    return [[sum(a * b for a, b in zip(row_a, col_b)) for col_b in zip(*B)] for row_a in A]

try:
    A = read_matrix('A')
    B = read_matrix('B')
    out = read_matrix('out')

    expected = multiply(A, B)

    if expected != out:
        print("VERIFICATION FAILED")
    else:
        print("VERIFICATION PASSED")

except Exception as e:
    print(f"Error: {e}")
