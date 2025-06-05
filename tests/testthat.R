# tests/testthat.R
# Test runner for the pilot study sample size calculator

library(testthat)
library(shiny)

# Source the main app to get functions
source("app.R", local = TRUE)

# Run all tests
test_dir("tests/testthat")
