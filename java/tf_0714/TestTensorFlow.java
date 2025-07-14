import org.tensorflow.TensorFlow;
import org.tensorflow.Graph;
import org.tensorflow.Session;
import org.tensorflow.Tensor;

public class TestTensorFlow {
    public static void main(String[] args) {
        System.out.println("TensorFlow version: " + TensorFlow.version());
        
        // Create a simple computation graph
        try (Graph g = new Graph()) {
            // Create a constant tensor
            try (Tensor<?> t = Tensor.create(42.0f)) {
                g.opBuilder("Const", "MyConst")
                    .setAttr("dtype", t.dataType())
                    .setAttr("value", t)
                    .build();
            }
            
            // Run the graph
            try (Session s = new Session(g);
                 Tensor<?> result = s.runner().fetch("MyConst").run().get(0)) {
                System.out.println("Result: " + result.floatValue());
                System.out.println("TensorFlow JNI is working correctly on ARM64!");
            }
        }
    }
}
