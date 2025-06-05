# run_tests.R
# Convenient script to run all tests with omnibus pass/fail

# Load required packages
if (!require(testthat)) {
    install.packages("testthat")
    library(testthat)
}

if (!require(shinytest2)) {
    message("Installing shinytest2 for app testing...")
    install.packages("shinytest2")
    library(shinytest2)
}

# Source the main app functions
source("app.R", local = TRUE)

run_tests <- function(){
# Run all tests and capture results
cat("Running pilot study calculator tests...\n\n")

# Run all tests in the testthat directory
test_results <- test_dir("tests/testthat", reporter = "summary")

# Get overall pass/fail status
total_tests <- sum(test_results$passed, test_results$failed, test_results$skipped)
failed_tests <- test_results$failed
passed_tests <- test_results$passed

cat("\n" , rep("=", 50), "\n")
cat("OVERALL TEST RESULTS\n")
cat(rep("=", 50), "\n")
cat("Total tests:", total_tests, "\n")
cat("Passed:", passed_tests, "\n")
cat("Failed:", failed_tests, "\n")

if (is.null(failed_tests)) {
    return(cat("\n✅ ALL TESTS PASSED - App is ready to use!\n"))
    overall_status <- "PASS"
} else {
    return(cat("\n❌ SOME TESTS FAILED - Check output above for details\n"))
    overall_status <- "FAIL"
}
}

run_tests()

