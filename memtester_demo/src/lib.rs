use libmemtester::MemoryTests;
use std::io::{stdout, Write};

pub fn run_test() {
    println!("Running memtester demo...");

    // Allocate 1 MB for testing
    let allocation_size = 1024 * 1024;
    
    // Create MemoryTests instance. 
    // The second argument `false` likely disables mlock/VirtualLock which might require privileges.
    let mem_tests_res = MemoryTests::new(allocation_size, false);

    match mem_tests_res {
        Ok(mut mem_tests) => {
            println!("Allocated {} bytes for testing.", allocation_size);
            
            let mut test_iter = mem_tests.get_iterator();
            
            // Print first test name
            if let Some(next_name) = test_iter.next_test_name() {
                print!("Test {}: running...", next_name);
                let _ = stdout().flush();
            }

            // Run tests
            while let Some((name, errors)) = test_iter.next() {
                println!("\r\x1B[2KTest {}: {} errors", name, errors);
                
                // Prepare for next test
                if let Some(next_name) = test_iter.next_test_name() {
                    print!("Test {}: running...", next_name);
                    let _ = stdout().flush();
                }
            }
            println!("All tests completed.");
        }
        Err(e) => {
            println!("Failed to initialize memory tests: {}", e);
        }
    }
}
