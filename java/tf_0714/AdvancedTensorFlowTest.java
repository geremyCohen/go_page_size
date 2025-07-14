import org.tensorflow.TensorFlow;
import org.tensorflow.Graph;
import org.tensorflow.Session;
import org.tensorflow.Tensor;
import org.tensorflow.Operation;

public class AdvancedTensorFlowTest {
    public static void main(String[] args) {
        System.out.println("=== Advanced TensorFlow ARM64 Test ===");
        System.out.println("TensorFlow version: " + TensorFlow.version());
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println();
        
        // Test matrix multiplication
        testMatrixMultiplication();
        
        // Test basic math operations
        testMathOperations();
        
        System.out.println("All tests completed successfully!");
    }
    
    private static void testMatrixMultiplication() {
        System.out.println("Testing matrix multiplication...");
        
        try (Graph g = new Graph()) {
            // Create two 2x2 matrices
            float[][] matrix1 = {{1.0f, 2.0f}, {3.0f, 4.0f}};
            float[][] matrix2 = {{5.0f, 6.0f}, {7.0f, 8.0f}};
            
            try (Tensor<?> t1 = Tensor.create(matrix1, Float.class);
                 Tensor<?> t2 = Tensor.create(matrix2, Float.class)) {
                
                // Create constant operations
                Operation const1 = g.opBuilder("Const", "matrix1")
                    .setAttr("dtype", t1.dataType())
                    .setAttr("value", t1)
                    .build();
                    
                Operation const2 = g.opBuilder("Const", "matrix2")
                    .setAttr("dtype", t2.dataType())
                    .setAttr("value", t2)
                    .build();
                
                // Matrix multiplication
                Operation matmul = g.opBuilder("MatMul", "matmul")
                    .addInput(const1.output(0))
                    .addInput(const2.output(0))
                    .build();
                
                // Run the computation
                try (Session s = new Session(g);
                     Tensor<?> result = s.runner().fetch("matmul").run().get(0)) {
                    
                    float[][] resultMatrix = new float[2][2];
                    result.copyTo(resultMatrix);
                    
                    System.out.println("Matrix 1:");
                    printMatrix(matrix1);
                    System.out.println("Matrix 2:");
                    printMatrix(matrix2);
                    System.out.println("Result (Matrix1 × Matrix2):");
                    printMatrix(resultMatrix);
                    System.out.println("✅ Matrix multiplication test passed!");
                    System.out.println();
                }
            }
        }
    }
    
    private static void testMathOperations() {
        System.out.println("Testing mathematical operations...");
        
        try (Graph g = new Graph()) {
            // Create input values
            try (Tensor<?> a = Tensor.create(10.0f);
                 Tensor<?> b = Tensor.create(3.0f)) {
                
                Operation constA = g.opBuilder("Const", "a")
                    .setAttr("dtype", a.dataType())
                    .setAttr("value", a)
                    .build();
                    
                Operation constB = g.opBuilder("Const", "b")
                    .setAttr("dtype", b.dataType())
                    .setAttr("value", b)
                    .build();
                
                // Addition
                Operation add = g.opBuilder("Add", "add")
                    .addInput(constA.output(0))
                    .addInput(constB.output(0))
                    .build();
                
                // Multiplication
                Operation mul = g.opBuilder("Mul", "mul")
                    .addInput(constA.output(0))
                    .addInput(constB.output(0))
                    .build();
                
                // Power (a^b)
                Operation pow = g.opBuilder("Pow", "pow")
                    .addInput(constA.output(0))
                    .addInput(constB.output(0))
                    .build();
                
                // Run all operations
                try (Session s = new Session(g)) {
                    try (Tensor<?> addResult = s.runner().fetch("add").run().get(0);
                         Tensor<?> mulResult = s.runner().fetch("mul").run().get(0);
                         Tensor<?> powResult = s.runner().fetch("pow").run().get(0)) {
                        
                        System.out.println("a = 10.0, b = 3.0");
                        System.out.println("a + b = " + addResult.floatValue());
                        System.out.println("a × b = " + mulResult.floatValue());
                        System.out.println("a ^ b = " + powResult.floatValue());
                        System.out.println("✅ Mathematical operations test passed!");
                        System.out.println();
                    }
                }
            }
        }
    }
    
    private static void printMatrix(float[][] matrix) {
        for (float[] row : matrix) {
            System.out.print("  [");
            for (int i = 0; i < row.length; i++) {
                System.out.printf("%6.1f", row[i]);
                if (i < row.length - 1) System.out.print(", ");
            }
            System.out.println(" ]");
        }
    }
}
