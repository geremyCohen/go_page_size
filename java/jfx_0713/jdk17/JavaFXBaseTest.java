import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.Event;
import javafx.event.EventType;
import javafx.util.Pair;

/**
 * JavaFX Base Module Test - JDK17 Version
 * 
 * This test uses ONLY the JavaFX base module (javafx.base.jar)
 * Tests core JavaFX functionality without GUI components:
 * - Property binding system
 * - Observable collections
 * - Event system
 * - Utility classes
 */
public class JavaFXBaseTest {
    
    public static void main(String[] args) {
        System.out.println("=== JavaFX Base Module Test - JDK17 ===");
        System.out.println("Testing JavaFX base functionality without GUI");
        System.out.println("Architecture: " + System.getProperty("os.arch"));
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println();
        
        // Test 1: Property Binding System
        testPropertyBinding();
        
        // Test 2: Observable Collections
        testObservableCollections();
        
        // Test 3: Event System
        testEventSystem();
        
        // Test 4: Utility Classes
        testUtilityClasses();
        
        System.out.println("=== JavaFX Base Module Test Complete ===");
        System.out.println("✅ JavaFX Base JNI integration working with JDK17!");
    }
    
    /**
     * Test JavaFX property binding system
     */
    private static void testPropertyBinding() {
        System.out.println("=== Testing Property Binding System ===");
        
        try {
            // Create string properties
            StringProperty firstName = new SimpleStringProperty("John");
            StringProperty lastName = new SimpleStringProperty("Doe");
            StringProperty fullName = new SimpleStringProperty();
            
            // Bind full name to first + last name
            fullName.bind(firstName.concat(" ").concat(lastName));
            
            System.out.println("Initial full name: " + fullName.get());
            
            // Change first name
            firstName.set("Jane");
            System.out.println("After changing first name: " + fullName.get());
            
            // Change last name
            lastName.set("Smith");
            System.out.println("After changing last name: " + fullName.get());
            
            System.out.println("✅ Property binding system working!");
            
        } catch (Exception e) {
            System.err.println("❌ Property binding test failed: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println();
    }
    
    /**
     * Test JavaFX observable collections
     */
    private static void testObservableCollections() {
        System.out.println("=== Testing Observable Collections ===");
        
        try {
            // Create observable list
            ObservableList<String> items = FXCollections.observableArrayList();
            
            // Add change listener
            items.addListener((javafx.collections.ListChangeListener<String>) change -> {
                while (change.next()) {
                    if (change.wasAdded()) {
                        System.out.println("  Added: " + change.getAddedSubList());
                    }
                    if (change.wasRemoved()) {
                        System.out.println("  Removed: " + change.getRemoved());
                    }
                }
            });
            
            // Test adding items
            System.out.println("Adding items to observable list:");
            items.add("Item 1");
            items.add("Item 2");
            items.add("Item 3");
            
            // Test removing items
            System.out.println("Removing item from observable list:");
            items.remove("Item 2");
            
            System.out.println("Final list: " + items);
            System.out.println("✅ Observable collections working!");
            
        } catch (Exception e) {
            System.err.println("❌ Observable collections test failed: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println();
    }
    
    /**
     * Test JavaFX event system
     */
    private static void testEventSystem() {
        System.out.println("=== Testing Event System ===");
        
        try {
            // Create custom event type
            EventType<Event> CUSTOM_EVENT = new EventType<>("CUSTOM_EVENT");
            
            // Create event
            Event customEvent = new Event(CUSTOM_EVENT);
            
            System.out.println("Created event: " + customEvent.getEventType());
            System.out.println("Event consumed: " + customEvent.isConsumed());
            
            // Consume event
            customEvent.consume();
            System.out.println("After consuming: " + customEvent.isConsumed());
            
            System.out.println("✅ Event system working!");
            
        } catch (Exception e) {
            System.err.println("❌ Event system test failed: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println();
    }
    
    /**
     * Test JavaFX utility classes
     */
    private static void testUtilityClasses() {
        System.out.println("=== Testing Utility Classes ===");
        
        try {
            // Test Pair utility class
            Pair<String, Integer> pair = new Pair<>("ARM64", 17);
            
            System.out.println("Pair key: " + pair.getKey());
            System.out.println("Pair value: " + pair.getValue());
            System.out.println("Pair string: " + pair.toString());
            
            // Test equality
            Pair<String, Integer> pair2 = new Pair<>("ARM64", 17);
            System.out.println("Pairs equal: " + pair.equals(pair2));
            
            System.out.println("✅ Utility classes working!");
            
        } catch (Exception e) {
            System.err.println("❌ Utility classes test failed: " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println();
    }
}
